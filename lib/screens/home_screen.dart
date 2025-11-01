import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_app/business_logic/auth-provider.dart';
import 'package:hotel_app/business_logic/home_provider.dart';
import 'package:hotel_app/models/search_result.dart';
import 'package:hotel_app/screens/hotel_result_screen.dart';
import 'package:provider/provider.dart';
import 'sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  final dynamic user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChange(String value) {
    final homeProvider = context.read<HomeProvider>();
    if (value.isNotEmpty) {
      homeProvider.performAutoCompleteSearch(value);
    } else {
      homeProvider.resetToDefault();
    }
  }

  void _handleClearSearch() {
    _searchController.clear();
    context.read<HomeProvider>().resetToDefault();
  }

  void _handleSearchTypeChange(String type) {
    final homeProvider = context.read<HomeProvider>();
    homeProvider.setSearchType(type);

    if (_searchController.text.isNotEmpty) {
      homeProvider.performAutoCompleteSearch(_searchController.text);
    } else {
      homeProvider.initialize();
    }
  }

  Future<void> _handleResultTap(SearchResult result) async {
    // Navigate to new screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelResultsScreen(searchResult: result),
      ),
    );
  }

  void _handleBackToSearch() {
    context.read<HomeProvider>().clearHotels();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(authProvider),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(child: _buildLocationResultsSection()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AuthProvider authProvider) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Text(
        'Discover Hotels',
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: CircleAvatar(
            radius: 16,
            backgroundImage: widget.user.photoURL != null
                ? NetworkImage(widget.user.photoURL!)
                : null,
            child: widget.user.photoURL == null
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          onPressed: () => _showProfileMenu(authProvider),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildSearchTypeFilter(homeProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _handleSearchChange,
      decoration: InputDecoration(
        hintText: 'Search hotels, cities, states...',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _handleClearSearch,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSearchTypeFilter(HomeProvider homeProvider) {
    final searchTypes = ['All', 'City', 'State', 'Country', 'Property'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: searchTypes
            .map(
              (type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type),
                  selected: homeProvider.selectedSearchType == type,
                  onSelected: (selected) => _handleSearchTypeChange(type),
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: homeProvider.selectedSearchType == type
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 12,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildLocationResultsSection() {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        if (homeProvider.isSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeProvider.searchResults.isEmpty && homeProvider.hasSearched) {
          return _buildEmptyState();
        }

        if (homeProvider.searchResults.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildLocationResultsList(homeProvider.searchResults);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for a different location',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationResultsList(List<SearchResult> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildLocationCard(results[index]);
      },
    );
  }

  Widget _buildLocationCard(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        /*onTap: () {
          log('hotel result tapped: ${result.searchArray}');
          // _handleResultTap(result);
        },*/
        onTap: () {
          final queryList = result.searchArray?['query'];

          if (queryList is List && queryList.isNotEmpty) {
            log('Query List: ${queryList.map((e) => e.toString()).toList()}');
          } else {
            log('No query list found in searchArray');
          }

          _handleResultTap(result);
        },

        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForType(result.type),
                  color: Colors.blue[700],
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (result.displayLocation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.displayLocation,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        result.type.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'city':
        return Icons.location_city;
      case 'state':
        return Icons.map;
      case 'country':
        return Icons.public;
      default:
        return Icons.place;
    }
  }

  void _showProfileMenu(AuthProvider authProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildProfileMenu(authProvider),
    );
  }

  Widget _buildProfileMenu(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: widget.user.photoURL != null
                ? NetworkImage(widget.user.photoURL!)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            widget.user.displayName ?? '',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            widget.user.email ?? '',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          if (authProvider.visitorToken != null) _buildVerifiedBadge(),
          const SizedBox(height: 20),
          _buildSignOutButton(authProvider),
        ],
      ),
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: Colors.green[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Device Verified',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(AuthProvider authProvider) {
    return ElevatedButton.icon(
      onPressed: () => _handleSignOut(authProvider),
      icon: const Icon(Icons.logout),
      label: const Text('Sign Out'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _handleSignOut(AuthProvider authProvider) async {
    Navigator.pop(context);
    await authProvider.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    }
  }
}
