const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();
const prisma = new PrismaClient();

router.post('/', authenticateToken, async (req, res) => {
  try {
    const { vehicleId, rating, comment } = req.body;

    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ error: 'Rating must be between 1 and 5' });
    }

    const review = await prisma.review.create({
      data: {
        userId: req.user.id,
        vehicleId,
        rating: parseInt(rating),
        comment
      }
    });

    const avgRating = await prisma.review.aggregate({
      where: { vehicleId },
      _avg: { rating: true }
    });

    await prisma.vehicle.update({
      where: { id: vehicleId },
      data: { rating: avgRating._avg.rating }
    });

    res.status(201).json({
      message: 'Review created',
      review
    });
  } catch (error) {
    console.error('Create review error:', error);
    res.status(500).json({ error: 'Failed to create review' });
  }
});

router.get('/vehicle/:vehicleId', async (req, res) => {
  try {
    const reviews = await prisma.review.findMany({
      where: { vehicleId: req.params.vehicleId },
      include: {
        user: {
          select: { name: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({ reviews });
  } catch (error) {
    console.error('Get reviews error:', error);
    res.status(500).json({ error: 'Failed to fetch reviews' });
  }
});

module.exports = router;
