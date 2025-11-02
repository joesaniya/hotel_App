import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_app/models/hotel_modal.dart';
import 'package:hotel_app/screens/bottom_sheet_widget/search_filter_bottomsheet.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;
  final SearchCriteria searchCriteria;

  const HotelDetailsScreen({
    super.key,
    required this.hotel,
    required this.searchCriteria,
  });

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDealIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelHeader(),
                _buildSearchSummaryCard(),
                _buildPricingCard(),
                _buildTabSection(),
                _buildTabContent(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
            ],
          ),
          child: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8),
              ],
            ),
            child: Icon(
              widget.hotel.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.hotel.isFavorite ? Colors.red : Colors.black87,
            ),
          ),
          onPressed: () {
          
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(background: _buildHotelImage()),
    );
  }

  Widget _buildHotelImage() {
    if (widget.hotel.propertyImage != null &&
        widget.hotel.propertyImage!.fullUrl.isNotEmpty) {
      return Image.network(
        widget.hotel.propertyImage!.fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[300]!, Colors.blue[600]!],
        ),
      ),
      child: const Center(
        child: Icon(Icons.hotel, size: 80, color: Colors.white),
      ),
    );
  }

  Widget _buildHotelHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.hotel.propertyName,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStarRating(widget.hotel.propertyStar),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.hotel.propertyType,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ),
          if (widget.hotel.propertyAddress != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.hotel.propertyAddress!.fullAddress,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (widget.hotel.googleReview != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 18, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        widget.hotel.googleReview!.overallRating
                            .toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.hotel.googleReview!.totalUserRating} reviews',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchSummaryCard() {
    final nights = widget.searchCriteria.checkOutDate
        .difference(widget.searchCriteria.checkInDate)
        .inDays;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Check-in',
            DateFormat(
              'MMM dd, yyyy',
            ).format(widget.searchCriteria.checkInDate),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.calendar_today,
            'Check-out',
            DateFormat(
              'MMM dd, yyyy',
            ).format(widget.searchCriteria.checkOutDate),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.nights_stay,
            'Duration',
            '$nights ${nights == 1 ? 'Night' : 'Nights'}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.hotel,
            'Rooms',
            '${widget.searchCriteria.rooms} ${widget.searchCriteria.rooms == 1 ? 'Room' : 'Rooms'}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.people,
            'Guests',
            '${widget.searchCriteria.adults} ${widget.searchCriteria.adults == 1 ? 'Adult' : 'Adults'}${widget.searchCriteria.children > 0 ? ' • ${widget.searchCriteria.children} ${widget.searchCriteria.children == 1 ? 'Child' : 'Children'}' : ''}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPricingCard() {
    final nights = widget.searchCriteria.checkOutDate
        .difference(widget.searchCriteria.checkInDate)
        .inDays;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.blue[100]!]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (widget.hotel.markedPrice != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Original Price',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  widget.hotel.markedPrice!.displayAmount,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price per night',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                widget.hotel.simplPriceList?.simplPrice.displayAmount ?? '₹0',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$nights ${nights == 1 ? 'Night' : 'Nights'} × ${widget.searchCriteria.rooms} ${widget.searchCriteria.rooms == 1 ? 'Room' : 'Rooms'}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                widget.hotel.propertyMinPrice?.displayAmount ?? '₹0',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.hotel.propertyMinPrice?.displayAmount ?? '₹0',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue[700],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[700],
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Amenities'),
          Tab(text: 'Policies'),
          Tab(text: 'Deals'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      color: Colors.white,
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [_buildAmenitiesTab(), _buildPoliciesTab(), _buildDealsTab()],
      ),
    );
  }

  Widget _buildAmenitiesTab() {
    if (widget.hotel.propertyPolicies == null) {
      return _buildEmptyState('No amenities information available');
    }

    final policies = widget.hotel.propertyPolicies!;
    final amenities = [
      if (policies.freeWifi) ('Free WiFi', Icons.wifi),
      if (policies.freeCancellation)
        ('Free Cancellation', Icons.cancel_outlined),
      if (policies.coupleFriendly) ('Couple Friendly', Icons.favorite_border),
      if (policies.suitableForChildren)
        ('Suitable for Children', Icons.child_care),
      if (policies.bachularsAllowed) ('Bachelors Allowed', Icons.groups),
      if (policies.petsAllowed) ('Pets Allowed', Icons.pets),
      if (policies.payAtHotel) ('Pay at Hotel', Icons.payment),
      if (policies.payNow) ('Pay Now', Icons.credit_card),
    ];

    if (amenities.isEmpty) {
      return _buildEmptyState('No amenities listed');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final (label, icon) = amenities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.green[700], size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.green[900],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPoliciesTab() {
    if (widget.hotel.propertyPolicies == null) {
      return _buildEmptyState('No policies information available');
    }

    final policies = widget.hotel.propertyPolicies!;
    final policyItems = [
      if (policies.cancelPolicy != null)
        ('Cancellation Policy', policies.cancelPolicy!),
      if (policies.childPolicy != null) ('Child Policy', policies.childPolicy!),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: policyItems.length,
      itemBuilder: (context, index) {
        final (title, description) = policyItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDealsTab() {
    if (widget.hotel.availableDeals.isEmpty) {
      return _buildEmptyState('No deals available');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.hotel.availableDeals.length,
      itemBuilder: (context, index) {
        final deal = widget.hotel.availableDeals[index];
        final isSelected = _selectedDealIndex == index;

        return GestureDetector(
          onTap: () => setState(() => _selectedDealIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[50] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue[700]! : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deal.headerName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deal.price.displayAmount,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: Colors.blue[700], size: 28),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
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
          size: 18,
          color: Colors.amber,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    widget.hotel.propertyMinPrice?.displayAmount ?? '₹0',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _handleBookNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Book Now',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBookNow() async {
    final deal = widget.hotel.availableDeals.isNotEmpty
        ? widget.hotel.availableDeals[_selectedDealIndex]
        : null;

    if (deal != null && deal.websiteUrl.isNotEmpty) {
      final url = Uri.parse(deal.websiteUrl);
      log('Url: $url');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open booking URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (widget.hotel.propertyUrl.isNotEmpty) {
      final url = Uri.parse(widget.hotel.propertyUrl);
      log('Url: $url');
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking URL not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}
