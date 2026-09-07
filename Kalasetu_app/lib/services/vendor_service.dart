import 'package:supabase_flutter/supabase_flutter.dart';

class VendorModel {
  final String id;
  final String name;
  final String companyType;
  final String logoIcon;
  final String category;
  final String location;
  final String description;
  final String minOrderQty;
  final String preferredMaterial;
  final String contactEmail;
  final double rating;

  VendorModel({
    required this.id,
    required this.name,
    required this.companyType,
    required this.logoIcon,
    required this.category,
    required this.location,
    required this.description,
    required this.minOrderQty,
    required this.preferredMaterial,
    required this.contactEmail,
    required this.rating,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] as String? ?? 'v_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'B2B Vendor',
      companyType: json['company_type'] as String? ?? 'Wholesale Buyer',
      logoIcon: json['logo_icon'] as String? ?? 'storefront',
      category: json['category'] as String? ?? 'Handicrafts',
      location: json['location'] as String? ?? 'India',
      description: json['description'] as String? ?? 'B2B wholesale purchaser for artisan goods.',
      minOrderQty: json['min_order_qty'] as String? ?? '20 Units',
      preferredMaterial: json['preferred_material'] as String? ?? 'All Handloom & Craft',
      contactEmail: json['contact_email'] as String? ?? 'b2b@artisanconnect.in',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }
}

class VendorService {
  static final _db = Supabase.instance.client;

  /// Sample mock vendors fallback if DB table is empty
  static final List<VendorModel> fallbackVendors = [
    VendorModel(
      id: 'v1',
      name: 'FabIndia B2B Sourcing',
      companyType: 'National Retail Chain',
      logoIcon: 'storefront',
      category: 'Handloom & Textiles',
      location: 'New Delhi, Delhi',
      description: 'Sourcing premium organic cotton handloom sarees, dupattas, and traditional home furnishings directly from verified artisan clusters across India.',
      minOrderQty: '20 Units',
      preferredMaterial: 'Organic Cotton & Silk',
      contactEmail: 'sourcing@fabindia-b2b.com',
      rating: 4.9,
    ),
    VendorModel(
      id: 'v2',
      name: 'Heritage Crafts Exporters',
      companyType: 'International Exporter',
      logoIcon: 'public',
      category: 'Pottery & Home Decor',
      location: 'Jaipur, Rajasthan',
      description: 'Exporting handcrafted terracotta, blue pottery, and brass decor items to luxury boutique stores in Europe and USA.',
      minOrderQty: '50 Units',
      preferredMaterial: 'Clay & Terracotta',
      contactEmail: 'procurement@heritagecrafts.in',
      rating: 4.8,
    ),
    VendorModel(
      id: 'v3',
      name: 'Cottage Handicrafts Collective',
      companyType: 'Government Emporium Buyer',
      logoIcon: 'account_balance',
      category: 'Woodwork & Metalcraft',
      location: 'Varanasi, Uttar Pradesh',
      description: 'Official procurement agency connecting rural artisans with state handicraft emporiums and cultural exhibitions nationwide.',
      minOrderQty: '15 Units',
      preferredMaterial: 'Sheesham Wood & Brass',
      contactEmail: 'orders@cottagecrafts.gov.in',
      rating: 4.7,
    ),
    VendorModel(
      id: 'v4',
      name: 'Artisanal Living Hotels',
      companyType: 'Boutique Hospitality Partner',
      logoIcon: 'hotel',
      category: 'Handmade Ceramics & Tableware',
      location: 'Udaipur, Rajasthan',
      description: 'Curating authentic handmade ceramics, clay dinnerware, and woven crafts for eco-luxury heritage resorts across Rajasthan & Goa.',
      minOrderQty: '30 Units',
      preferredMaterial: 'Ceramic & Terracotta',
      contactEmail: 'vendor@artisanalliving.com',
      rating: 4.9,
    ),
  ];

  /// Fetch vendors from Supabase `vendors` table or return fallback if table not queryable yet
  static Future<List<VendorModel>> getVendors() async {
    try {
      final rows = await _db.from('vendors').select().order('rating', ascending: false);
      if (rows.isNotEmpty) {
        return (rows as List).map((r) => VendorModel.fromJson(r as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return fallbackVendors;
  }
}
