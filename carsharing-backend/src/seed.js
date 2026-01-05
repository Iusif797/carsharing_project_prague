const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  const adminPassword = await bcrypt.hash('admin123', 10);
  
  const admin = await prisma.user.upsert({
    where: { email: 'admin@praguecarsharing.com' },
    update: {},
    create: {
      email: 'admin@praguecarsharing.com',
      password: adminPassword,
      name: 'Admin User',
      role: 'ADMIN'
    }
  });

  console.log('✅ Admin user created:', admin.email);

  const vehicles = [
    {
      name: 'Tesla Model 3',
      brand: 'Tesla',
      model: 'Model 3',
      year: 2023,
      licensePlate: 'PRG-TS-001',
      city: 'Prague',
      latitude: 50.0875,
      longitude: 14.4213,
      pricePerMinute: 0.35,
      pricePerHour: 15,
      pricePerDay: 80,
      pricePerWeek: 450,
      fuelType: 'electric',
      transmission: 'automatic',
      seats: 5,
      imageUrl: 'https://images.unsplash.com/photo-1560958089-b8a1929cea89'
    },
    {
      name: 'BMW 3 Series',
      brand: 'BMW',
      model: '3 Series',
      year: 2022,
      licensePlate: 'PRG-BM-002',
      city: 'Prague',
      latitude: 50.088,
      longitude: 14.425,
      pricePerMinute: 0.40,
      pricePerHour: 18,
      pricePerDay: 90,
      pricePerWeek: 500,
      fuelType: 'petrol',
      transmission: 'automatic',
      seats: 5,
      imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e'
    },
    {
      name: 'Škoda Octavia',
      brand: 'Škoda',
      model: 'Octavia',
      year: 2023,
      licensePlate: 'BRN-SK-001',
      city: 'Brno',
      latitude: 49.1951,
      longitude: 16.6068,
      pricePerMinute: 0.30,
      pricePerHour: 12,
      pricePerDay: 70,
      pricePerWeek: 400,
      fuelType: 'petrol',
      transmission: 'manual',
      seats: 5,
      imageUrl: 'https://images.unsplash.com/photo-1583121274602-3e2820c69888'
    },
    {
      name: 'Volkswagen Golf',
      brand: 'Volkswagen',
      model: 'Golf',
      year: 2022,
      licensePlate: 'KV-VW-001',
      city: 'Karlovy Vary',
      latitude: 50.2329,
      longitude: 12.8716,
      pricePerMinute: 0.28,
      pricePerHour: 10,
      pricePerDay: 65,
      pricePerWeek: 380,
      fuelType: 'diesel',
      transmission: 'manual',
      seats: 5,
      imageUrl: 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d'
    }
  ];

  for (const vehicle of vehicles) {
    await prisma.vehicle.upsert({
      where: { licensePlate: vehicle.licensePlate },
      update: {},
      create: vehicle
    });
  }

  console.log(`✅ Created ${vehicles.length} vehicles`);
  console.log('');
  console.log('🎉 Seeding complete!');
  console.log('');
  console.log('📧 Admin credentials:');
  console.log('   Email: admin@praguecarsharing.com');
  console.log('   Password: admin123');
  console.log('');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
