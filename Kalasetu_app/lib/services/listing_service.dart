import 'package:supabase_flutter/supabase_flutter.dart';

class ListingService {
  static final _db = Supabase.instance.client;

  static String get _userId => _db.auth.currentUser!.id;

  /// Insert a new listing row and return its generated id.
  static Future<String> createListing({
    required String imagePath,
    required Map<String, dynamic> listingData,
  }) async {
    final payload = <String, dynamic>{
      'user_id': _userId,
      'image_path': imagePath,
      'title': listingData['title'],
      'description_en': listingData['description_en'],
      'description_hi': listingData['description_hi'],
      'specifications': listingData['specifications'] ?? {},
      'category': listingData['category'],
      'material': listingData['material'],
      'price': listingData['price'],
      'status': 'draft',
    };

    if (listingData['price_min'] != null) {
      payload['price_min'] = listingData['price_min'];
    }
    if (listingData['price_max'] != null) {
      payload['price_max'] = listingData['price_max'];
    }

    final row = await _db.from('listings').insert(payload).select('id').single();
    return row['id'] as String;
  }

  static Future<void> publishListing(String id, {String channel = 'amazon', String? vendorId}) async {
    final updatePayload = <String, dynamic>{
      'status': 'published',
      'channel': channel,
    };
    if (vendorId != null) {
      updatePayload['vendor_id'] = vendorId;
    }

    try {
      await _db.from('listings').update(updatePayload).eq('id', id);
    } catch (_) {
      // Fallback if schema lacks channel/vendor_id columns
      await _db.from('listings').update({'status': 'published'}).eq('id', id);
    }
  }

  /// Records proposal in `vendor_submissions` table and updates listing channel to B2B
  static Future<void> submitToVendor({
    required String listingId,
    required String vendorId,
  }) async {
    try {
      await _db.from('vendor_submissions').insert({
        'listing_id': listingId,
        'vendor_id': vendorId,
        'user_id': _userId,
        'status': 'submitted',
        'sent_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}

    await publishListing(listingId, channel: 'b2b', vendorId: vendorId);
  }

  static Future<void> updateListing(String id, Map<String, dynamic> updatedFields) async {
    await _db.from('listings').update(updatedFields).eq('id', id);
  }

  static Future<List<Map<String, dynamic>>> getMyListings() async {
    final rows = await _db
        .from('listings')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> deleteListing(String id) async {
    await _db.from('listings').delete().eq('id', id);
  }
}
