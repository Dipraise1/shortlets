const now = new Date();
const daysAgo = (d) => new Date(now - d * 86400000);
const hoursAgo = (h) => new Date(now - h * 3600000);

export const stats = {
  totalProperties: 16,
  activeProperties: 13,
  totalUsers: 8,
  totalListers: 3,
  pendingVerifications: 2,
  totalRequests: 3,
  pendingRequests: 2,
  totalRevenue: 4527000,
};

export const properties = [
  { id: '1', name: 'Green Hangout Place', location: 'Wuse 2, Abuja', city: 'Abuja', price: 85000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 3, bathrooms: 2, isActive: true, createdAt: daysAgo(60), rating: 4.5, imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400' },
  { id: '2', name: 'Elegant Apartment', location: 'Maitama, Abuja', city: 'Abuja', price: 18000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 4, bathrooms: 3, isActive: true, createdAt: daysAgo(45), rating: 4.8, imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400' },
  { id: '3', name: 'Modern Luxury Villa', location: 'Asokoro, Abuja', city: 'Abuja', price: 140000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 5, bathrooms: 4, isActive: true, createdAt: daysAgo(90), rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400' },
  { id: '4', name: 'Cozy Studio Apartment', location: 'Garki, Abuja', city: 'Abuja', price: 40000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 1, bathrooms: 1, isActive: false, createdAt: daysAgo(30), rating: 4.3, imageUrl: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400' },
  { id: '5', name: 'Executive Penthouse', location: 'Maitama, Abuja', city: 'Abuja', price: 200000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 6, bathrooms: 5, isActive: true, createdAt: daysAgo(15), rating: 4.9, imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400' },
  { id: 'abj-h1', name: '4 Bedroom Detached House', location: 'Gwarinpa, Abuja', city: 'Abuja', price: 350000, listingType: 'rent', propertyType: 'house', bedrooms: 4, bathrooms: 3, isActive: true, createdAt: daysAgo(100), rating: 4.6, imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400' },
  { id: 'lagos-1', name: 'Luxury Apartment Lekki', location: 'Lekki Phase 1, Lagos', city: 'Lagos', price: 120000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 3, bathrooms: 2, isActive: true, createdAt: daysAgo(20), rating: 4.6, imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400' },
  { id: 'lagos-2', name: 'Victoria Island Penthouse', location: 'Victoria Island, Lagos', city: 'Lagos', price: 250000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 4, bathrooms: 3, isActive: true, createdAt: daysAgo(55), rating: 4.9, imageUrl: 'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=400' },
  { id: 'lagos-3', name: 'Cozy Studio Ikeja', location: 'Ikeja, Lagos', city: 'Lagos', price: 35000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 1, bathrooms: 1, isActive: false, createdAt: daysAgo(40), rating: 4.2, imageUrl: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=400' },
  { id: 'lagos-h1', name: '4 Bedroom Semi-Detached', location: 'Lekki Phase 2, Lagos', city: 'Lagos', price: 500000, listingType: 'rent', propertyType: 'house', bedrooms: 4, bathrooms: 4, isActive: true, createdAt: daysAgo(70), rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=400' },
  { id: 'ph-1', name: 'Riverside Apartment', location: 'GRA Phase 2, Port Harcourt', city: 'Port Harcourt', price: 75000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 3, bathrooms: 2, isActive: true, createdAt: daysAgo(25), rating: 4.5, imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400' },
  { id: 'ph-2', name: 'Modern Villa Rumuokoro', location: 'Rumuokoro, Port Harcourt', city: 'Port Harcourt', price: 110000, listingType: 'shortlet', propertyType: 'apartment', bedrooms: 4, bathrooms: 3, isActive: true, createdAt: daysAgo(50), rating: 4.7, imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400' },
];

export const users = [
  { id: 'u001', name: 'Adaeze Okonkwo', email: 'adaeze@gmail.com', role: 'renter', status: 'active', joinedAt: daysAgo(45), bookingsCount: 3 },
  { id: 'u002', name: 'Emeka Nwosu', email: 'emeka.nwosu@yahoo.com', role: 'renter', status: 'active', joinedAt: daysAgo(120), bookingsCount: 7 },
  { id: 'u003', name: 'LS Woltoh', email: 'lswoltoh07@gmail.com', role: 'lister', status: 'active', joinedAt: daysAgo(200), bookingsCount: 0 },
  { id: 'u004', name: 'Fatima Bello', email: 'fatima.b@outlook.com', role: 'renter', status: 'active', joinedAt: daysAgo(30), bookingsCount: 1 },
  { id: 'u005', name: 'Tunde Bakare', email: 'tunde.bakare@gmail.com', role: 'lister', status: 'active', joinedAt: daysAgo(90), bookingsCount: 0 },
  { id: 'u006', name: 'Ngozi Adeyemi', email: 'ngozi.adeyemi@gmail.com', role: 'renter', status: 'suspended', joinedAt: daysAgo(60), bookingsCount: 2 },
  { id: 'u007', name: 'Chukwuma Nwosu', email: 'chukwuma@gmail.com', role: 'renter', status: 'active', joinedAt: daysAgo(15), bookingsCount: 0 },
  { id: 'u008', name: 'Boma Dike', email: 'boma.dike@email.com', role: 'lister', status: 'active', joinedAt: daysAgo(75), bookingsCount: 0 },
];

export const verifications = [
  { id: 'v001', fullName: 'Amaka Obi', email: 'amaka.obi@gmail.com', phone: '+2348012345678', businessName: 'Obi Properties Ltd', status: 'pending', submittedAt: hoursAgo(5) },
  { id: 'v002', fullName: 'Segun Adeleke', email: 'segun.adeleke@yahoo.com', phone: '+2349055678901', businessName: 'Adeleke Real Estate', status: 'pending', submittedAt: hoursAgo(20) },
  { id: 'v003', fullName: 'LS Woltoh', email: 'lswoltoh07@gmail.com', phone: '+2348012345678', businessName: 'Woltoh Properties', status: 'approved', submittedAt: daysAgo(10) },
  { id: 'v004', fullName: 'Eze Chisom', email: 'chisom.eze@email.com', phone: '+2348098765432', businessName: '', status: 'rejected', submittedAt: daysAgo(14) },
];

export const requests = [
  { id: 'req001', propertyName: 'Green Hangout Place', renterName: 'Adaeze Okonkwo', renterEmail: 'adaeze@gmail.com', renterPhone: '+2348031234567', dateInfo: 'Check-in: 20 Jun 2026 | Check-out: 23 Jun 2026 (3 nights)', totalPrice: 255000, message: "Hi, I'm visiting for a business trip. Is the place pet-friendly?", createdAt: hoursAgo(2), status: 'pending' },
  { id: 'req002', propertyName: '4 Bedroom Detached House', renterName: 'Emeka Nwosu', renterEmail: 'emeka.nwosu@yahoo.com', renterPhone: '+2349055678901', dateInfo: 'Duration: 12 months', totalPrice: 4200000, message: 'We are a family of 4. Is the boys quarters separate? When can we view?', createdAt: daysAgo(1), status: 'pending' },
  { id: 'req003', propertyName: 'Elegant Apartment', renterName: 'Fatima Bello', renterEmail: 'fatima.b@outlook.com', renterPhone: '+2348098765432', dateInfo: 'Check-in: 1 Jul 2026 | Check-out: 5 Jul 2026 (4 nights)', totalPrice: 72000, message: '', createdAt: daysAgo(3), status: 'accepted' },
];
