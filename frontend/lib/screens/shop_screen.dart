import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/shop_service.dart';
import '../services/gamification_service.dart';

// ─── Styles ──────────────────────────────────────────────────────────────────
final _shopTitleStyle = GoogleFonts.outfit(fontWeight: FontWeight.bold);

final _gemBalanceStyle = GoogleFonts.outfit(fontWeight: FontWeight.bold);

final _itemNameStyle = GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16);

final _itemDescStyle = GoogleFonts.outfit(fontSize: 12, color: Colors.white54);

class ShopScreen extends StatefulWidget {
  final String userId;

  const ShopScreen({super.key, required this.userId});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final ShopService _shopService = ShopService();
  final GamificationService _gamificationService = GamificationService();
  
  bool _isLoading = true;
  List<dynamic> _items = [];
  Map<String, dynamic>? _userProfile;
  List<String> _inventory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final items = await _shopService.getShopItems();
      final profile = await _gamificationService.getUserProfile(widget.userId);
      
      setState(() {
        _items = items;
        _userProfile = profile;
        _inventory = List<String>.from(profile['inventory'] ?? []);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading shop: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePurchase(String itemId, int cost) async {
    try {
      await _shopService.purchaseItem(widget.userId, itemId);
      await _loadData(); // Refresh gems and inventory
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleEquip(String itemId) async {
    try {
      await _shopService.equipItem(widget.userId, itemId);
      await _loadData(); // Refresh equipped status
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Equipped!'), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Equip failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1014),
      appBar: AppBar(
        title: Text('Shop', style: _shopTitleStyle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_userProfile != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '${_userProfile!['gems']}',
                        style: _gemBalanceStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('No items available in the shop.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isOwned = _inventory.contains(item['id']);
                    final isEquipped = _userProfile?['equipped_banner'] == item['id'] || 
                                     _userProfile?['equipped_effect'] == item['id'];

                    return _buildItemCard(item, isOwned, isEquipped);
                  },
                ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, bool isOwned, bool isEquipped) {
    final bool isBanner = item['type'] == 'banner';
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E212B),
        borderRadius: BorderRadius.circular(20),
        border: isEquipped ? Border.all(color: Colors.blueAccent, width: 2) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: isBanner ? Colors.blueGrey.withOpacity(0.3) : Colors.purple.withOpacity(0.2),
              child: Center(
                child: Icon(
                  isBanner ? Icons.image_rounded : Icons.face_retouching_natural_rounded,
                  size: 48,
                  color: Colors.white24,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: _itemNameStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'],
                  style: _itemDescStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isEquipped 
                        ? null 
                        : isOwned 
                            ? () => _handleEquip(item['id'])
                            : () => _handlePurchase(item['id'], item['cost']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOwned ? Colors.blueGrey : Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.white10,
                    ),
                    child: isOwned 
                        ? Text(isEquipped ? 'Equipped' : 'Equip')
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('💎 ', style: TextStyle(fontSize: 12)),
                              Text('${item['cost']}'),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
