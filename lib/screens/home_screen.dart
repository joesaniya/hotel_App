import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_app/business_logic/auth-provider.dart';
import 'package:hotel_app/business_logic/home_provider.dart';
import 'package:hotel_app/models/search_result.dart';
import 'package:hotel_app/models/static_modal.dart';
import 'package:hotel_app/screens/app_setting_screen.dart';
import 'package:hotel_app/screens/bottom_sheet_widget/search_filter_bottomsheet.dart';
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
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initialize();
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions =
            _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearchChange(String value) {
    final homeProvider = context.read<HomeProvider>();

    setState(() {
      _showSuggestions = value.isNotEmpty;
    });

    if (value.isNotEmpty && value.length >= 3) {
      homeProvider.performAutoCompleteSearch(value);
    } else if (value.isEmpty) {
      homeProvider.resetToDefault();
    }
  }

  void _handleClearSearch() {
    _searchController.clear();
    setState(() {
      _showSuggestions = false;
    });
    context.read<HomeProvider>().resetToDefault();
    _searchFocusNode.unfocus();
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

  void _handleSuggestionTap(SearchResult result) {
    setState(() {
      _showSuggestions = false;
    });
    _searchFocusNode.unfocus();

    if (result.type.toLowerCase() == 'bypropertyname' ||
        result.type.toLowerCase() == 'hotel') {
      _navigateToHotelDetails(result);
    } else {
      _showSearchFilterSheet(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(authProvider),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showSuggestions = false;
          });
          _searchFocusNode.unfocus();
        },
        child: Stack(
          children: [
            Column(
              children: [
                _buildSearchSection(),
                Expanded(child: _buildMainContent(homeProvider)),
              ],
            ),
            if (_showSuggestions && _searchController.text.length >= 3)
              _buildSearchSuggestionsOverlay(),
          ],
        ),
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
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
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
          child: Column(children: [_buildSearchBarWithFilters(homeProvider)]),
        );
      },
    );
  }

  Widget _buildSearchBarWithFilters(HomeProvider homeProvider) {
    final isSearching = _searchController.text.isNotEmpty;

    return Column(
      children: [
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _handleSearchChange,
          onTap: () {
            if (_searchController.text.isNotEmpty) {
              setState(() {
                _showSuggestions = true;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Search hotels, cities, states...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
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
        ),
        if (isSearching) ...[
          const SizedBox(height: 12),
          _buildInlineSearchTypeFilter(homeProvider),
        ],
      ],
    );
  }

  Widget _buildInlineSearchTypeFilter(HomeProvider homeProvider) {
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
                  backgroundColor: Colors.grey[200],
                  labelStyle: GoogleFonts.poppins(
                    color: homeProvider.selectedSearchType == type
                        ? Colors.white
                        : Colors.black87,
                    fontSize: 12,
                    fontWeight: homeProvider.selectedSearchType == type
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSearchSuggestionsOverlay() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: _buildSearchSuggestions(homeProvider),
          );
        },
      ),
    );
  }

  Widget _buildSearchSuggestions(HomeProvider homeProvider) {
    if (homeProvider.isSearching) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (homeProvider.searchResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No suggestions found',
          style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: homeProvider.searchResults.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final result = homeProvider.searchResults[index];
        return _buildSuggestionItem(result);
      },
    );
  }

  Widget _buildSuggestionItem(SearchResult result) {
    return InkWell(
      onTap: () => _handleSuggestionTap(result),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForType(result.type),
                color: Colors.blue[700],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.displayLocation.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.displayLocation,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getDisplayType(result.type),
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayType(String type) {
    final typeMap = {
      'bypropertyname': 'HOTEL',
      'bycity': 'CITY',
      'bystate': 'STATE',
      'bycountry': 'COUNTRY',
      'bystreet': 'STREET',
    };
    return typeMap[type.toLowerCase()] ?? type.toUpperCase();
  }

  Widget _buildMainContent(HomeProvider homeProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildPopularHotelsSection(homeProvider),
          const SizedBox(height: 24),
          _buildHotDealsSection(homeProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPopularHotelsSection(HomeProvider homeProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Hotels',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.orange[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: homeProvider.popularHotels.length,
            itemBuilder: (context, index) {
              return _buildPopularHotelCard(homeProvider.popularHotels[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularHotelCard(StaticHotel hotel) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Selected: ${hotel.name}')));
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(hotel.imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.location,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${hotel.price}/night',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hotel.rating,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotDealsSection(HomeProvider homeprovider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hot Deals',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.orange[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: homeprovider.hotDeals.length,
            itemBuilder: (context, index) {
              return _buildHotDealCard(homeprovider.hotDeals[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHotDealCard(StaticDeal deal) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Selected: ${deal.name}')));
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(deal.imageUrl),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  deal.discount,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deal.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          deal.location,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              deal.rating,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${deal.price}/night',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchFilterSheet(SearchResult result) {
    final homeProvider = context.read<HomeProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => SearchFilterBottomSheet(
          initialCriteria: homeProvider.searchCriteria,
          onSearch: (criteria) async {
            homeProvider.setSearchCriteria(criteria);
            Navigator.pop(context);

            _searchController.clear();
            setState(() {
              _showSuggestions = false;
            });

            await Future.delayed(const Duration(milliseconds: 100));
            if (mounted) {
              _navigateToHotelResults(result, criteria);
            }
          },
        ),
      ),
    );
  }

  Future<void> _navigateToHotelDetails(SearchResult result) async {
    try {
      _searchController.clear();
      setState(() {
        _showSuggestions = false;
      });

      final criteria = SearchCriteria(
        checkInDate: DateTime.now().add(const Duration(days: 1)),
        checkOutDate: DateTime.now().add(const Duration(days: 2)),
        rooms: 1,
        adults: 2,
        children: 0,
        accommodations: ['all'],
        excludedSearchTypes: [],
        minPrice: 0,
        maxPrice: 30000,
      );

      log('Navigating to hotel details for: ${result.name}');
      await _navigateToHotelResults(result, criteria);
    } catch (e) {
      log(' Error navigating to hotel details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void showFilterSheet(
    SearchResult searchResult,
    SearchCriteria searchCriteria,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => SearchFilterBottomSheet(
          initialCriteria: searchCriteria,
          onSearch: (newCriteria) async {
            context.read<HomeProvider>().clearHotels();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HotelResultsScreen(
                  searchResult: searchResult,
                  searchCriteria: searchCriteria,
                ),
              ),
            );
            /*  if (searchResult.type == 'Hotel') {
              log(
                'Hotel selected, navigating to details screen.:${searchResult.type}',
              );
            } else {
              log('Navigating to search results screen.:${searchResult.type}');
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelResultsScreen(
                    searchResult: searchResult,
                    searchCriteria: searchCriteria,
                  ),
                ),
              );
            }*/
          },
        ),
      ),
    );
  }

  Future<void> _navigateToHotelResults(
    SearchResult result,
    SearchCriteria criteria,
  ) async {
    try {
      final queryList = result.getSearchQueryList();

      if (queryList.isEmpty) {
        log(' Warning: No query list found, using result ID as fallback');
        log('Result ID: ${result.id}');
        log('Result Type: ${result.type}');
      } else {
        log(' Query List: ${queryList.join(", ")}');
      }

      log('Search Type: ${result.getSearchTypeForAPI()}');
      log('Check-in: ${criteria.checkIn}');
      log('Check-out: ${criteria.checkOut}');
      log('Rooms: ${criteria.rooms}, Adults: ${criteria.adults}');
      /* if (result.type == 'Hotel') {
        log('Hotel selected, navigating to details screen.:${result.type}');
      } else {
        log('Navigating to hotel results screen.:${result.type}');
        /* await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HotelResultsScreen(
              searchResult: result,
              searchCriteria: criteria,
            ),
          ),
        );*/
      }
      showFilterSheet(result, criteria);

      */
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HotelResultsScreen(
            searchResult: result,
            searchCriteria: criteria,
          ),
        ),
      );
    } catch (e) {
      log(' Error navigating to hotel results: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  IconData _getIconForType(String type) {
    final typeMap = {
      'bypropertyname': Icons.hotel,
      'bycity': Icons.location_city,
      'bystate': Icons.map,
      'bycountry': Icons.public,
      'bystreet': Icons.place,
    };
    return typeMap[type.toLowerCase()] ?? Icons.place;
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
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.settings, size: 20, color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppSettingsScreen()),
                );
              },
            ),
          ),
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
