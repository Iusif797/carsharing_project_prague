const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

router.post('/', authenticateToken, async (req, res) => {
  try {
    const { vehicleId, pricingPlan, totalPrice } = req.body;

    const vehicle = await prisma.vehicle.findUnique({
      where: { id: vehicleId }
    });

    if (!vehicle) {
      return res.status(404).json({ error: 'Vehicle not found' });
    }

    if (vehicle.status !== 'AVAILABLE') {
      return res.status(400).json({ error: 'Vehicle not available' });
    }

    const booking = await prisma.booking.create({
      data: {
        userId: req.user.id,
        vehicleId,
        pricingPlan,
        totalPrice: parseFloat(totalPrice),
        startTime: new Date()
      },
      include: {
        vehicle: true
      }
    });

    await prisma.vehicle.update({
      where: { id: vehicleId },
      data: { status: 'BOOKED' }
    });

    res.status(201).json({
      message: 'Booking created successfully',
      booking
    });
  } catch (error) {
    console.error('Create booking error:', error);
    res.status(500).json({ error: 'Failed to create booking' });
  }
});

router.get('/my', authenticateToken, async (req, res) => {
  try {
    const bookings = await prisma.booking.findMany({
      where: { userId: req.user.id },
      include: {
        vehicle: true
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ bookings });
  } catch (error) {
    console.error('Get bookings error:', error);
    res.status(500).json({ error: 'Failed to fetch bookings' });
  }
});

router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const booking = await prisma.booking.findFirst({
      where: {
        id: req.params.id,
        userId: req.user.id
      },
      include: {
        vehicle: true,
        user: {
          select: { name: true, email: true }
        }
      }
    });

    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }

    res.json(booking);
  } catch (error) {
    console.error('Get booking error:', error);
    res.status(500).json({ error: 'Failed to fetch booking' });
  }
});

router.patch('/:id/complete', authenticateToken, async (req, res) => {
  try {
    const booking = await prisma.booking.findFirst({
      where: {
        id: req.params.id,
        userId: req.user.id,
        status: 'ACTIVE'
      }
    });

    if (!booking) {
      return res.status(404).json({ error: 'Active booking not found' });
    }

    const updatedBooking = await prisma.booking.update({
      where: { id: req.params.id },
      data: {
        status: 'COMPLETED',
        endTime: new Date()
      }
    });

    await prisma.vehicle.update({
      where: { id: booking.vehicleId },
      data: { status: 'AVAILABLE' }
    });

    await prisma.user.update({
      where: { id: req.user.id },
      data: {
        totalTrips: { increment: 1 },
        totalSpent: { increment: booking.totalPrice }
      }
    });

    res.json({
      message: 'Booking completed',
      booking: updatedBooking
    });
  } catch (error) {
    console.error('Complete booking error:', error);
    res.status(500).json({ error: 'Failed to complete booking' });
  }
});

router.delete('/:id', authenticateToken, async (req, res) => {
  try {
    const booking = await prisma.booking.findFirst({
      where: {
        id: req.params.id,
        userId: req.user.id,
        status: 'ACTIVE'
      }
    });

    if (!booking) {
      return res.status(404).json({ error: 'Active booking not found' });
    }

    await prisma.booking.update({
      where: { id: req.params.id },
      data: { status: 'CANCELLED' }
    });

    await prisma.vehicle.update({
      where: { id: booking.vehicleId },
      data: { status: 'AVAILABLE' }
    });

    res.json({ message: 'Booking cancelled' });
  } catch (error) {
    console.error('Cancel booking error:', error);
    res.status(500).json({ error: 'Failed to cancel booking' });
  }
});

module.exports = router;
