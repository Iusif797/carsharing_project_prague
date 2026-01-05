const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken, isAdmin } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

router.use(authenticateToken);
router.use(isAdmin);

router.get('/dashboard', async (req, res) => {
  try {
    const [
      totalUsers,
      totalVehicles,
      activeBookings,
      totalRevenue,
      recentBookings
    ] = await Promise.all([
      prisma.user.count(),
      prisma.vehicle.count({ where: { isActive: true } }),
      prisma.booking.count({ where: { status: 'ACTIVE' } }),
      prisma.booking.aggregate({
        where: { status: 'COMPLETED' },
        _sum: { totalPrice: true }
      }),
      prisma.booking.findMany({
        take: 10,
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: { id: true, name: true, email: true }
          },
          vehicle: {
            select: { id: true, name: true, brand: true }
          }
        }
      })
    ]);

    res.json({
      stats: {
        totalUsers,
        totalVehicles,
        activeBookings,
        totalRevenue: totalRevenue._sum.totalPrice || 0
      },
      recentBookings
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ error: 'Failed to load dashboard' });
  }
});

router.get('/users', async (req, res) => {
  try {
    const { page = 1, limit = 20, search } = req.query;
    const skip = (page - 1) * limit;

    const where = search
      ? {
          OR: [
            { email: { contains: search, mode: 'insensitive' } },
            { name: { contains: search, mode: 'insensitive' } }
          ]
        }
      : {};

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          email: true,
          name: true,
          phoneNumber: true,
          role: true,
          isActive: true,
          totalTrips: true,
          totalSpent: true,
          memberSince: true,
          createdAt: true,
          _count: {
            select: {
              bookings: true,
              trips: true
            }
          }
        }
      }),
      prisma.user.count({ where })
    ]);

    res.json({
      users,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

router.get('/users/:id', async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.params.id },
      include: {
        bookings: {
          include: { vehicle: true },
          orderBy: { createdAt: 'desc' },
          take: 10
        },
        trips: {
          include: { vehicle: true },
          orderBy: { createdAt: 'desc' },
          take: 10
        },
        reviews: {
          include: { vehicle: true },
          orderBy: { createdAt: 'desc' }
        }
      }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

router.patch('/users/:id/status', async (req, res) => {
  try {
    const { isActive } = req.body;

    const user = await prisma.user.update({
      where: { id: req.params.id },
      data: { isActive: Boolean(isActive) }
    });

    res.json({
      message: `User ${isActive ? 'activated' : 'deactivated'}`,
      user
    });
  } catch (error) {
    console.error('Update user status error:', error);
    res.status(500).json({ error: 'Failed to update user status' });
  }
});

router.get('/vehicles', async (req, res) => {
  try {
    const vehicles = await prisma.vehicle.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        _count: {
          select: {
            bookings: true,
            trips: true
          }
        }
      }
    });

    res.json({ vehicles });
  } catch (error) {
    console.error('Get vehicles error:', error);
    res.status(500).json({ error: 'Failed to fetch vehicles' });
  }
});

router.post('/vehicles', async (req, res) => {
  try {
    const vehicleData = req.body;

    const vehicle = await prisma.vehicle.create({
      data: {
        ...vehicleData,
        latitude: parseFloat(vehicleData.latitude),
        longitude: parseFloat(vehicleData.longitude),
        year: parseInt(vehicleData.year),
        batteryLevel: parseInt(vehicleData.batteryLevel || 100),
        fuelLevel: parseInt(vehicleData.fuelLevel || 100),
        pricePerMinute: parseFloat(vehicleData.pricePerMinute),
        pricePerHour: parseFloat(vehicleData.pricePerHour),
        pricePerDay: parseFloat(vehicleData.pricePerDay),
        pricePerWeek: parseFloat(vehicleData.pricePerWeek),
        seats: parseInt(vehicleData.seats)
      }
    });

    res.status(201).json({
      message: 'Vehicle created',
      vehicle
    });
  } catch (error) {
    console.error('Create vehicle error:', error);
    res.status(500).json({ error: 'Failed to create vehicle' });
  }
});

router.patch('/vehicles/:id', async (req, res) => {
  try {
    const vehicleData = req.body;

    const vehicle = await prisma.vehicle.update({
      where: { id: req.params.id },
      data: vehicleData
    });

    res.json({
      message: 'Vehicle updated',
      vehicle
    });
  } catch (error) {
    console.error('Update vehicle error:', error);
    res.status(500).json({ error: 'Failed to update vehicle' });
  }
});

router.delete('/vehicles/:id', async (req, res) => {
  try {
    await prisma.vehicle.update({
      where: { id: req.params.id },
      data: { isActive: false }
    });

    res.json({ message: 'Vehicle deactivated' });
  } catch (error) {
    console.error('Delete vehicle error:', error);
    res.status(500).json({ error: 'Failed to deactivate vehicle' });
  }
});

router.get('/bookings', async (req, res) => {
  try {
    const { status, page = 1, limit = 20 } = req.query;
    const skip = (page - 1) * limit;

    const where = status ? { status } : {};

    const [bookings, total] = await Promise.all([
      prisma.booking.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: { id: true, name: true, email: true }
          },
          vehicle: {
            select: { id: true, name: true, brand: true, city: true }
          }
        }
      }),
      prisma.booking.count({ where })
    ]);

    res.json({
      bookings,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get bookings error:', error);
    res.status(500).json({ error: 'Failed to fetch bookings' });
  }
});

router.get('/analytics', async (req, res) => {
  try {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const [
      revenueByDay,
      popularVehicles,
      topUsers,
      cityStats
    ] = await Promise.all([
      prisma.booking.groupBy({
        by: ['createdAt'],
        where: {
          status: 'COMPLETED',
          createdAt: { gte: thirtyDaysAgo }
        },
        _sum: { totalPrice: true },
        _count: true
      }),
      prisma.vehicle.findMany({
        orderBy: { totalTrips: 'desc' },
        take: 10,
        select: {
          id: true,
          name: true,
          brand: true,
          totalTrips: true,
          rating: true
        }
      }),
      prisma.user.findMany({
        orderBy: { totalSpent: 'desc' },
        take: 10,
        select: {
          id: true,
          name: true,
          email: true,
          totalTrips: true,
          totalSpent: true
        }
      }),
      prisma.vehicle.groupBy({
        by: ['city'],
        _count: true,
        where: { isActive: true }
      })
    ]);

    res.json({
      revenueByDay,
      popularVehicles,
      topUsers,
      cityStats
    });
  } catch (error) {
    console.error('Analytics error:', error);
    res.status(500).json({ error: 'Failed to fetch analytics' });
  }
});

module.exports = router;
