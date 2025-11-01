import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_app/business_logic/auth-provider.dart';
import 'package:hotel_app/business_logic/home_provider.dart';
import 'package:hotel_app/models/search_result.dart';
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
    // Initialize home provider
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
      homeProvider.performSearch(value);
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
      homeProvider.performSearch(_searchController.text);
    } else {
      homeProvider.initialize();
    }
  }

  void _handleResultTap(SearchResult result) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected: ${result.name}')));
  }

  void _handleViewDetails(SearchResult result) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('View details: ${result.name}')));
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
          Expanded(child: _buildResultsSection()),
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

  Widget _buildResultsSection() {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        if (homeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeProvider.results.isEmpty && homeProvider.hasSearched) {
          return _buildEmptyState();
        }

        if (homeProvider.results.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildResultsList(homeProvider.results);
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

  Widget _buildResultsList(List<SearchResult> results) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildResultCard(results[index]);
      },
    );
  }

  Widget _buildResultCard(SearchResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _handleResultTap(result),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildResultImage(result), _buildResultContent(result)],
        ),
      ),
    );
  }

  Widget _buildResultImage(SearchResult result) {
    if (result.imageUrl != null && result.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          result.imageUrl!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
        ),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[300]!, Colors.blue[500]!],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Icon(Icons.hotel, size: 64, color: Colors.white),
      ),
    );
  }

  Widget _buildResultContent(SearchResult result) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultHeader(result),
          if (result.displayLocation.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildResultLocation(result),
          ],
          const SizedBox(height: 12),
          _buildViewDetailsButton(result),
        ],
      ),
    );
  }

  Widget _buildResultHeader(SearchResult result) {
    return Row(
      children: [
        Expanded(
          child: Text(
            result.name,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    );
  }

  Widget _buildResultLocation(SearchResult result) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            result.displayLocation,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildViewDetailsButton(SearchResult result) {
    return ElevatedButton(
      onPressed: () => _handleViewDetails(result),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        'View Details',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    );
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
