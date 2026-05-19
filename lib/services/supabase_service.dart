import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static bool get isConfigured {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static User? get currentUser => isConfigured ? client.auth.currentUser : null;
  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStream =>
      isConfigured ? client.auth.onAuthStateChange : const Stream.empty();

  static Future<AuthResponse?> signInWithEmail(
      String email, String password) async {
    if (!isConfigured) return null;
    return await client.auth
        .signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse?> signUpWithEmail(String email, String password,
      {String? name}) async {
    if (!isConfigured) return null;
    return await client.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'full_name': name} : null,
    );
  }

  static Future<void> signOut() async {
    if (!isConfigured) return;
    await client.auth.signOut();
  }

  // ── Properties ────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchProperties({
    String? city,
    String? listingType,
    String? propertyType,
  }) async {
    if (!isConfigured || !isLoggedIn) return [];
    var query = client
        .from('properties')
        .select('*, agents(*)')
        .eq('is_active', true);

    if (city != null && city.isNotEmpty && city != 'All') {
      query = query.eq('city', city);
    }
    if (listingType != null &&
        listingType.isNotEmpty &&
        listingType != 'all') {
      query = query.eq('listing_type', listingType);
    }
    if (propertyType != null &&
        propertyType.isNotEmpty &&
        propertyType != 'all') {
      query = query.eq('property_type', propertyType);
    }

    final response =
        await query.order('rating', ascending: false).limit(50);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> fetchPropertyById(
      String propertyId) async {
    if (!isConfigured) return null;
    final response = await client
        .from('properties')
        .select('*, agents(*)')
        .eq('id', propertyId)
        .maybeSingle();
    return response;
  }

  // ── Favorites ─────────────────────────────────────────────────────────────

  static Future<Set<String>> fetchFavoriteIds() async {
    if (!isConfigured || !isLoggedIn) return {};
    final response = await client
        .from('favorites')
        .select('property_id')
        .eq('user_id', currentUser!.id);
    return Set<String>.from(
        response.map((f) => f['property_id'] as String));
  }

  static Future<List<Map<String, dynamic>>> fetchFavoriteProperties() async {
    if (!isConfigured || !isLoggedIn) return [];
    final response = await client
        .from('favorites')
        .select('property_id, properties(*, agents(*))')
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(
        response.map((f) => f['properties'] as Map<String, dynamic>));
  }

  static Future<bool> toggleFavorite(String propertyId) async {
    if (!isConfigured || !isLoggedIn) return false;
    final existing = await client
        .from('favorites')
        .select('id')
        .eq('user_id', currentUser!.id)
        .eq('property_id', propertyId)
        .maybeSingle();

    if (existing != null) {
      await client
          .from('favorites')
          .delete()
          .eq('user_id', currentUser!.id)
          .eq('property_id', propertyId);
      return false;
    } else {
      await client.from('favorites').insert({
        'user_id': currentUser!.id,
        'property_id': propertyId,
      });
      return true;
    }
  }

  // ── Conversations ─────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchConversations() async {
    if (!isConfigured || !isLoggedIn) return [];
    final response = await client
        .from('conversations')
        .select('*, agents(id, name, avatar_url), properties(id, name)')
        .eq('user_id', currentUser!.id)
        .order('last_message_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> findOrCreateConversation({
    required String agentId,
    String? propertyId,
  }) async {
    if (!isConfigured || !isLoggedIn) return null;

    // Try to find existing conversation for this property
    final query = client
        .from('conversations')
        .select()
        .eq('user_id', currentUser!.id)
        .eq('agent_id', agentId);

    final existing = propertyId != null
        ? await query.eq('property_id', propertyId).maybeSingle()
        : await query.maybeSingle();

    if (existing != null) return existing;

    final created = await client.from('conversations').insert({
      'user_id': currentUser!.id,
      'agent_id': agentId,
      if (propertyId != null) 'property_id': propertyId,
    }).select().single();
    return created;
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchMessages(
      String conversationId) async {
    if (!isConfigured) return [];
    final response = await client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    if (!isConfigured || !isLoggedIn) return;
    await client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': currentUser!.id,
      'content': content,
    });
  }

  static Future<void> markMessagesRead(String conversationId) async {
    if (!isConfigured || !isLoggedIn) return;
    await client
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', currentUser!.id);
  }

  static RealtimeChannel subscribeToMessages({
    required String conversationId,
    required void Function(Map<String, dynamic>) onInsert,
  }) {
    return client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) => onInsert(payload.newRecord),
        )
        .subscribe();
  }

  // ── Bookings ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> createBooking({
    required String propertyId,
    required DateTime checkIn,
    required DateTime checkOut,
    required double totalPrice,
    String? notes,
  }) async {
    if (!isConfigured || !isLoggedIn) return null;
    final response = await client.from('bookings').insert({
      'user_id': currentUser!.id,
      'property_id': propertyId,
      'check_in': checkIn.toIso8601String().split('T')[0],
      'check_out': checkOut.toIso8601String().split('T')[0],
      'total_price': totalPrice,
      if (notes != null) 'notes': notes,
    }).select().single();
    return response;
  }

  static Future<List<Map<String, dynamic>>> fetchBookings() async {
    if (!isConfigured || !isLoggedIn) return [];
    final response = await client
        .from('bookings')
        .select('*, properties(name, image_url, location)')
        .eq('user_id', currentUser!.id)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> fetchProfile() async {
    if (!isConfigured || !isLoggedIn) return null;
    return await client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();
  }

  static Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
  }) async {
    if (!isConfigured || !isLoggedIn) return;
    await client.from('profiles').update({
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    }).eq('id', currentUser!.id);
  }
}
