import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_app/business_logic/home_provider.dart';
import 'package:hotel_app/models/hotel_modal.dart';
import 'package:hotel_app/models/search_result.dart';
import 'package:hotel_app/screens/bottom_sheet_widget/search_filter_bottomsheet.dart';
import 'package:hotel_app/screens/home_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HotelResultsScreen extends StatefulWidget {
  final SearchResult searchResult;
  final SearchCriteria searchCriteria;

  const HotelResultsScreen({
    super.key,
    required this.searchResult,
    required this.searchCriteria,
  });

  @override
  State<HotelResultsScreen> createState() => _HotelResultsScreenState();
}

class _HotelResultsScreenState extends State<HotelResultsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    log('searchresult:${widget.searchResult}');
    log('searchcriteria:${widget.searchCriteria}');
    // Fetch hotels when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().selectLocationAndFetchHotels(
        widget.searchResult,
        widget.searchCriteria,
      );
    });

    // Setup pagination listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<HomeProvider>().loadMoreHotels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchSummary(),
          _buildLocationHeader(),
          Expanded(child: _buildHotelResults()),
        ],
      ),
      // floatingActionButton: _buildFilterButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () {
          context.read<HomeProvider>().clearHotels();
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Available Hotels',
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSearchSummary() {
    final criteria = widget.searchCriteria;
    final nights = criteria.checkOutDate
        .difference(criteria.checkInDate)
        .inDays;

    return Container(
      width: double.infinity,
      color: Colors.blue[50],
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${DateFormat('MMM dd').format(criteria.checkInDate)} - ${DateFormat('MMM dd, yyyy').format(criteria.checkOutDate)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$nights ${nights == 1 ? 'Night' : 'Nights'} • ${criteria.rooms} ${criteria.rooms == 1 ? 'Room' : 'Rooms'} • ${criteria.adults} ${criteria.adults == 1 ? 'Adult' : 'Adults'}${criteria.children > 0 ? ' • ${criteria.children} ${criteria.children == 1 ? 'Child' : 'Children'}' : ''}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showFilterSheet,
            icon: Icon(Icons.tune, color: Colors.blue[700]),
            tooltip: 'Modify Search',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForType(widget.searchResult.type),
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.searchResult.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.searchResult.displayLocation.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.searchResult.displayLocation,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
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
                  widget.searchResult.type.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHotelResults() {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        if (homeProvider.hotels.isEmpty && homeProvider.isLoadingHotels) {
          return const Center(child: CircularProgressIndicator());
        }

        if (homeProvider.hotels.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            _buildResultsCount(homeProvider.hotels.length),
            Expanded(child: _buildHotelList(homeProvider)),
          ],
        );
      },
    );
  }

  Widget _buildResultsCount(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey[100],
      child: Text(
        '$count ${count == 1 ? 'Property' : 'Properties'} Found',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Hotels Available',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.tune),
            label: const Text('Modify Search'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelList(HomeProvider homeProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount:
          homeProvider.hotels.length + (homeProvider.isLoadingHotels ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == homeProvider.hotels.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _buildHotelCard(homeProvider.hotels[index], index + 1);
      },
    );
  }

  Widget _buildHotelCard(Hotel hotel, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _handleHotelTap(hotel),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildHotelImage(hotel),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$index',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildHotelContent(hotel),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelImage(Hotel hotel) {
    if (hotel.propertyImage != null &&
        hotel.propertyImage!.fullUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          hotel.propertyImage!.fullUrl,
          height: 200,
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
      height: 200,
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

  Widget _buildHotelContent(Hotel hotel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hotel.propertyName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildStarRating(hotel.propertyStar),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hotel.propertyType,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (hotel.propertyAddress != null)
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${hotel.propertyAddress!.city}, ${hotel.propertyAddress!.state}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (hotel.googleReview != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        hotel.googleReview!.overallRating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${hotel.googleReview!.totalUserRating} reviews',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (hotel.propertyPolicies?.freeWifi == true)
                _buildAmenityChip('Free WiFi', Icons.wifi),
              if (hotel.propertyPolicies?.freeCancellation == true)
                _buildAmenityChip('Free Cancellation', Icons.cancel_outlined),
              if (hotel.propertyPolicies?.coupleFriendly == true)
                _buildAmenityChip('Couple Friendly', Icons.favorite_border),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hotel.markedPrice != null)
                      Text(
                        hotel.markedPrice!.displayAmount,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                        ),
                      ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          hotel.propertyMinPrice?.displayAmount ?? '₹0',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '/night',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => _handleHotelTap(hotel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(int stars) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < stars ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        ),
      ),
    );
  }

  Widget _buildAmenityChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.green[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return FloatingActionButton.extended(
      onPressed: _showFilterSheet,
      backgroundColor: Colors.blue,
      icon: const Icon(Icons.tune),
      label: Text(
        'Filters',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => SearchFilterBottomSheet(
          initialCriteria: widget.searchCriteria,
          onSearch: (newCriteria) {
            context.read<HomeProvider>().clearHotels();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HotelResultsScreen(
                  searchResult: widget.searchResult,
                  searchCriteria: newCriteria,
                ),
              ),
            );
          },
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

  void _handleHotelTap(Hotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HotelDetailsScreen(
          hotel: hotel,
          searchCriteria: widget.searchCriteria,
        ),
      ),
    );
  }
}
