class Property {
  final String id;
  final String name;
  final String location;
  final double price;
  final String imageUrl;
  final String description;
  final int bedrooms;
  final int bathrooms;
  final String propertyArea;
  final int cctv;
  final int parkingSpots;
  final int year;
  final Agent agent;
  final double rating;
  final String reviewerName;
  final String reviewerImage;

  Property({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.bedrooms,
    required this.bathrooms,
    required this.propertyArea,
    required this.cctv,
    required this.parkingSpots,
    required this.year,
    required this.agent,
    required this.rating,
    required this.reviewerName,
    required this.reviewerImage,
  });
}

class Agent {
  final String name;
  final String email;
  final String imageUrl;
  final String? phone;

  Agent({
    required this.name,
    required this.email,
    required this.imageUrl,
    this.phone,
  });
}

// Sample data for Abuja properties
class PropertyData {
  static List<Property> getAbujaProperties() {
    return [
      Property(
        id: '1',
        name: 'Green Hangout Place',
        location: 'Wuse 2, Abuja',
        price: 85000.00,
        imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        description: 'This luxurious apartment is perfectly situated in Wuse 2, Abuja, offering modern living at its finest. The property boasts all contemporary amenities, with stunning views and easy access to shopping centers and restaurants.',
        bedrooms: 3,
        bathrooms: 2,
        propertyArea: '120 sqm',
        cctv: 10,
        parkingSpots: 2,
        year: 2024,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.5,
        reviewerName: 'Kw Ahayan',
        reviewerImage: 'https://i.pravatar.cc/150?img=33',
      ),
      Property(
        id: '2',
        name: 'Elegant Apartment',
        location: 'Maitama, Abuja',
        price: 18000.00,
        imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
        description: 'This luxurious builder floor is perfectly situated in Maitama, Abuja, offering modern living at its finest. The property boasts all contemporary amenities, with spacious rooms and premium finishes throughout.',
        bedrooms: 4,
        bathrooms: 3,
        propertyArea: '180 sqm',
        cctv: 10,
        parkingSpots: 6,
        year: 2025,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.8,
        reviewerName: 'Md Liakat',
        reviewerImage: 'https://i.pravatar.cc/150?img=1',
      ),
      Property(
        id: '3',
        name: 'Modern Luxury Villa',
        location: 'Asokoro, Abuja',
        price: 140000.00,
        imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
        description: 'A stunning modern villa in the heart of Asokoro with premium amenities and breathtaking views of the city.',
        bedrooms: 5,
        bathrooms: 4,
        propertyArea: '250 sqm',
        cctv: 15,
        parkingSpots: 4,
        year: 2023,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.7,
        reviewerName: 'Kw Ahayan',
        reviewerImage: 'https://i.pravatar.cc/150?img=33',
      ),
      Property(
        id: '4',
        name: 'Cozy Studio Apartment',
        location: 'Garki, Abuja',
        price: 40000.00,
        imageUrl: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
        description: 'Perfect for short stays in the heart of Garki. This cozy studio offers all essential amenities and is close to major business districts.',
        bedrooms: 1,
        bathrooms: 1,
        propertyArea: '45 sqm',
        cctv: 5,
        parkingSpots: 1,
        year: 2024,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.3,
        reviewerName: 'Md Liakat',
        reviewerImage: 'https://i.pravatar.cc/150?img=1',
      ),
      Property(
        id: '5',
        name: 'Executive Penthouse',
        location: 'Maitama, Abuja',
        price: 200000.00,
        imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
        description: 'Luxurious penthouse with panoramic city views. Perfect for executives and families seeking premium accommodation in Maitama.',
        bedrooms: 6,
        bathrooms: 5,
        propertyArea: '350 sqm',
        cctv: 20,
        parkingSpots: 8,
        year: 2024,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.9,
        reviewerName: 'Kw Ahayan',
        reviewerImage: 'https://i.pravatar.cc/150?img=33',
      ),
    ];
  }

  static List<Property> getLagosProperties() {
    return [
      Property(
        id: 'lagos-1',
        name: 'Luxury Apartment Lekki',
        location: 'Lekki Phase 1, Lagos',
        price: 120000.00,
        imageUrl: 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
        description: 'Modern luxury apartment in the heart of Lekki Phase 1, close to the beach and major shopping centers.',
        bedrooms: 3,
        bathrooms: 2,
        propertyArea: '140 sqm',
        cctv: 12,
        parkingSpots: 2,
        year: 2024,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.6,
        reviewerName: 'Guest',
        reviewerImage: 'https://i.pravatar.cc/150?img=33',
      ),
      Property(
        id: 'lagos-2',
        name: 'Victoria Island Penthouse',
        location: 'Victoria Island, Lagos',
        price: 250000.00,
        imageUrl: 'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800',
        description: 'Stunning penthouse with ocean views in Victoria Island. Perfect for business executives and luxury travelers.',
        bedrooms: 4,
        bathrooms: 3,
        propertyArea: '200 sqm',
        cctv: 15,
        parkingSpots: 3,
        year: 2023,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.9,
        reviewerName: 'Guest',
        reviewerImage: 'https://i.pravatar.cc/150?img=1',
      ),
      Property(
        id: 'lagos-3',
        name: 'Cozy Studio Ikeja',
        location: 'Ikeja, Lagos',
        price: 35000.00,
        imageUrl: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
        description: 'Affordable studio apartment in Ikeja, close to the airport and business district.',
        bedrooms: 1,
        bathrooms: 1,
        propertyArea: '50 sqm',
        cctv: 5,
        parkingSpots: 1,
        year: 2024,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.2,
        reviewerName: 'Guest',
        reviewerImage: 'https://i.pravatar.cc/150?img=33',
      ),
    ];
  }

  static List<Property> getPortHarcourtProperties() {
    return [
      Property(
        id: 'ph-1',
        name: 'Riverside Apartment',
        location: 'GRA Phase 2, Port Harcourt',
        price: 75000.00,
        imageUrl: 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
        description: 'Beautiful apartment in the Government Reserved Area, close to the city center and major amenities.',
        bedrooms: 3,
        bathrooms: 2,
        propertyArea: '130 sqm',
        cctv: 10,
        parkingSpots: 2,
        year: 2024,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.5,
        reviewerName: 'Guest',
        reviewerImage: 'https://i.pravatar.cc/150?img=33',
      ),
      Property(
        id: 'ph-2',
        name: 'Modern Villa Rumuokoro',
        location: 'Rumuokoro, Port Harcourt',
        price: 110000.00,
        imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
        description: 'Spacious modern villa in Rumuokoro with all amenities. Perfect for families and extended stays.',
        bedrooms: 4,
        bathrooms: 3,
        propertyArea: '180 sqm',
        cctv: 12,
        parkingSpots: 4,
        year: 2023,
        agent: Agent(
          name: 'LS Woltoh',
          email: 'lswoltoh07@gmail.com',
          imageUrl: 'https://i.pravatar.cc/150?img=12',
        ),
        rating: 4.7,
        reviewerName: 'Guest',
        reviewerImage: 'https://i.pravatar.cc/150?img=1',
      ),
    ];
  }

  static List<Property> getAllNigeriaProperties() {
    // Return a mix of properties from all cities
    return [
      ...getAbujaProperties(),
      ...getLagosProperties(),
      ...getPortHarcourtProperties(),
    ];
  }
}

