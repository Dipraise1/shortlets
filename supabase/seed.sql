-- ============================================================
-- Rosera Seed Data
-- ============================================================

-- Insert default agent
insert into public.agents (id, name, email, phone, avatar_url, verified) values
  ('a1000000-0000-0000-0000-000000000001', 'LS Woltoh', 'lswoltoh07@gmail.com', '+2348012345678', 'https://i.pravatar.cc/150?img=12', true),
  ('a1000000-0000-0000-0000-000000000002', 'Rosera Admin', 'admin@rosera.app', '+2348098765432', 'https://i.pravatar.cc/150?img=5', true);

-- ============================================================
-- Abuja Properties
-- ============================================================
insert into public.properties (id, agent_id, name, location, city, price, image_url, description, bedrooms, bathrooms, property_area, cctv, parking_spots, year_built, property_type, listing_type, rating) values
  ('p1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'Green Hangout Place', 'Wuse 2, Abuja', 'Abuja', 85000, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800', 'Luxurious apartment in Wuse 2 with modern amenities, stunning views and easy access to shopping centers and restaurants.', 3, 2, '120 sqm', 10, 2, 2024, 'apartment', 'shortlet', 4.5),
  ('p1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'Elegant Apartment', 'Maitama, Abuja', 'Abuja', 18000, 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800', 'Luxurious floor apartment in Maitama with spacious rooms and premium finishes throughout.', 4, 3, '180 sqm', 10, 6, 2025, 'apartment', 'shortlet', 4.8),
  ('p1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000001', 'Modern Luxury Villa', 'Asokoro, Abuja', 'Abuja', 140000, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800', 'A stunning modern villa in Asokoro with premium amenities and breathtaking views of the city.', 5, 4, '250 sqm', 15, 4, 2023, 'apartment', 'shortlet', 4.7),
  ('p1000000-0000-0000-0000-000000000004', 'a1000000-0000-0000-0000-000000000001', 'Cozy Studio Apartment', 'Garki, Abuja', 'Abuja', 40000, 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800', 'Perfect studio for short stays in Garki, close to major business districts.', 1, 1, '45 sqm', 5, 1, 2024, 'apartment', 'shortlet', 4.3),
  ('p1000000-0000-0000-0000-000000000005', 'a1000000-0000-0000-0000-000000000001', 'Executive Penthouse', 'Maitama, Abuja', 'Abuja', 200000, 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800', 'Luxurious penthouse with panoramic city views, perfect for executives seeking premium accommodation.', 6, 5, '350 sqm', 20, 8, 2024, 'apartment', 'shortlet', 4.9),
  -- Abuja Houses for Rent
  ('p1000000-0000-0000-0000-000000000006', 'a1000000-0000-0000-0000-000000000001', '4 Bedroom Detached House', 'Gwarinpa, Abuja', 'Abuja', 350000, 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800', 'Spacious 4-bedroom detached house in Gwarinpa estate with a large compound, boys quarters, and 24/7 security.', 4, 3, '220 sqm', 8, 3, 2022, 'house', 'rent', 4.6),
  ('p1000000-0000-0000-0000-000000000007', 'a1000000-0000-0000-0000-000000000001', '3 Bedroom Terrace House', 'Life Camp, Abuja', 'Abuja', 200000, 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800', 'Modern 3-bedroom terrace house in a serene Life Camp estate with fitted kitchen and all-rooms en-suite.', 3, 3, '160 sqm', 6, 2, 2023, 'house', 'rent', 4.5),
  ('p1000000-0000-0000-0000-000000000008', 'a1000000-0000-0000-0000-000000000001', '5 Bedroom Luxury Mansion', 'Asokoro, Abuja', 'Abuja', 650000, 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?w=800', 'Stunning luxury mansion in Asokoro with private pool, cinema room, and smart home technology.', 5, 5, '400 sqm', 20, 6, 2024, 'house', 'rent', 4.9);

-- ============================================================
-- Lagos Properties
-- ============================================================
insert into public.properties (id, agent_id, name, location, city, price, image_url, description, bedrooms, bathrooms, property_area, cctv, parking_spots, year_built, property_type, listing_type, rating) values
  ('p2000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'Luxury Apartment Lekki', 'Lekki Phase 1, Lagos', 'Lagos', 120000, 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800', 'Modern luxury apartment in Lekki Phase 1, close to the beach and major shopping centers.', 3, 2, '140 sqm', 12, 2, 2024, 'apartment', 'shortlet', 4.6),
  ('p2000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'Victoria Island Penthouse', 'Victoria Island, Lagos', 'Lagos', 250000, 'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800', 'Stunning penthouse with ocean views in Victoria Island, perfect for business executives.', 4, 3, '200 sqm', 15, 3, 2023, 'apartment', 'shortlet', 4.9),
  ('p2000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000001', 'Cozy Studio Ikeja', 'Ikeja, Lagos', 'Lagos', 35000, 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800', 'Affordable studio apartment in Ikeja, close to the airport and business district.', 1, 1, '50 sqm', 5, 1, 2024, 'apartment', 'shortlet', 4.2),
  -- Lagos Houses for Rent
  ('p2000000-0000-0000-0000-000000000004', 'a1000000-0000-0000-0000-000000000001', '4 Bedroom Semi-Detached', 'Lekki Phase 2, Lagos', 'Lagos', 500000, 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800', 'Beautiful semi-detached house in Lekki Phase 2 with a private garden, fitted kitchen, and smart home features.', 4, 4, '250 sqm', 10, 3, 2023, 'house', 'rent', 4.7),
  ('p2000000-0000-0000-0000-000000000005', 'a1000000-0000-0000-0000-000000000001', '3 Bedroom Bungalow', 'Surulere, Lagos', 'Lagos', 150000, 'https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=800', 'Well-maintained 3-bedroom bungalow in Surulere with spacious compound and steady power supply.', 3, 2, '130 sqm', 4, 2, 2021, 'house', 'rent', 4.3);

-- ============================================================
-- Port Harcourt Properties
-- ============================================================
insert into public.properties (id, agent_id, name, location, city, price, image_url, description, bedrooms, bathrooms, property_area, cctv, parking_spots, year_built, property_type, listing_type, rating) values
  ('p3000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'Riverside Apartment', 'GRA Phase 2, Port Harcourt', 'Port Harcourt', 75000, 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800', 'Beautiful apartment in the GRA close to the city center and major amenities.', 3, 2, '130 sqm', 10, 2, 2024, 'apartment', 'shortlet', 4.5),
  ('p3000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000001', 'Modern Villa Rumuokoro', 'Rumuokoro, Port Harcourt', 'Port Harcourt', 110000, 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800', 'Spacious modern villa in Rumuokoro with all amenities, perfect for families and extended stays.', 4, 3, '180 sqm', 12, 4, 2023, 'apartment', 'shortlet', 4.7),
  ('p3000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000001', '4 Bedroom Detached House', 'Old GRA, Port Harcourt', 'Port Harcourt', 280000, 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800', 'Fully detached 4-bedroom house in Old GRA with large compound, diesel generator, and constant water supply.', 4, 4, '200 sqm', 8, 3, 2022, 'house', 'rent', 4.5);
