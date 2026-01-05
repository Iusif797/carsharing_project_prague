const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

router.use(authenticateToken);

router.get('/me', async (req, res) => {
  try {
    const user = await prisma.user.findUnique({
      where: { id: req.user.id },
      select: {
        id: true,
        email: true,
        name: true,
        phoneNumber: true,
        driversLicense: true,
        totalTrips: true,
        totalSpent: true,
        memberSince: true
      }
    });

    res.json(user);
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

router.patch('/me', async (req, res) => {
  try {
    const { name, phoneNumber, driversLicense } = req.body;

    const user = await prisma.user.update({
      where: { id: req.user.id },
      data: { name, phoneNumber, driversLicense }
    });

    res.json({
      message: 'Profile updated',
      user
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

module.exports = router;
