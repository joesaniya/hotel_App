import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final Function(SearchCriteria) onSearch;
  final SearchCriteria? initialCriteria;

  const SearchFilterBottomSheet({
    super.key,
    required this.onSearch,
    this.initialCriteria,
  });

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late int _rooms;
  late int _adults;
  late int _children;
  late List<String> _selectedAccommodations;
  late List<String> _excludedSearchTypes;
  late double _minPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    if (widget.initialCriteria != null) {
      _checkInDate = widget.initialCriteria!.checkInDate;
      _checkOutDate = widget.initialCriteria!.checkOutDate;
      _rooms = widget.initialCriteria!.rooms;
      _adults = widget.initialCriteria!.adults;
      _children = widget.initialCriteria!.children;
      _selectedAccommodations = List.from(
        widget.initialCriteria!.accommodations,
      );
      _excludedSearchTypes = List.from(
        widget.initialCriteria!.excludedSearchTypes,
      );
      _minPrice = widget.initialCriteria!.minPrice;
      _maxPrice = widget.initialCriteria!.maxPrice;
    } else {
      _checkInDate = DateTime.now().add(const Duration(days: 1));
      _checkOutDate = DateTime.now().add(const Duration(days: 2));
      _rooms = 1;
      _adults = 2;
      _children = 0;
      _selectedAccommodations = ['all'];
      _excludedSearchTypes = [];
      _minPrice = 0;
      _maxPrice = 30000;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSection(),
                  const SizedBox(height: 24),
                  _buildGuestsSection(),
                  const SizedBox(height: 24),
                  _buildAccommodationSection(),
                  const SizedBox(height: 24),
                  _buildPriceRangeSection(),
                  const SizedBox(height: 24),
                  _buildExcludeSection(),
                  const SizedBox(height: 32),
                  _buildSearchButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Search Filters',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check-in & Check-out',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateCard(
                label: 'Check-in',
                date: _checkInDate,
                onTap: () => _selectDate(context, true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateCard(
                label: 'Check-out',
                date: _checkOutDate,
                onTap: () => _selectDate(context, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateCard({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rooms & Guests',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildCounter(
          'Rooms',
          _rooms,
          (value) => setState(() => _rooms = value),
        ),
        const SizedBox(height: 12),
        _buildCounter(
          'Adults',
          _adults,
          (value) => setState(() => _adults = value),
        ),
        const SizedBox(height: 12),
        _buildCounter(
          'Children',
          _children,
          (value) => setState(() => _children = value),
        ),
      ],
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed:
                    value > (label == 'Rooms' || label == 'Adults' ? 1 : 0)
                    ? () => onChanged(value - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: Colors.blue[700],
              ),
              SizedBox(
                width: 40,
                child: Center(
                  child: Text(
                    value.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: value < 10 ? () => onChanged(value + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.blue[700],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationSection() {
    final accommodations = [
      'All',
      'Hotel',
      'Resort',
      'Boat House',
      'Bed & Breakfast',
      'Guest House',
      'Holiday Home',
      'Cottage',
      'Apartment',
      'Home Stay',
      'Hostel',
      'Camp Sites/Tent',
      'Co-living',
      'Villa',
      'Motel',
      'Capsule Hotel',
      'Dome Hotel',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accommodation Type',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: accommodations.map((type) {
            final key = type
                .toLowerCase()
                .replaceAll(' ', '')
                .replaceAll('&', 'and');
            final isSelected =
                _selectedAccommodations.contains('all') && type == 'All' ||
                _selectedAccommodations.contains(key);

            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (type == 'All') {
                    _selectedAccommodations = selected ? ['all'] : [];
                  } else {
                    if (selected) {
                      _selectedAccommodations.remove('all');
                      _selectedAccommodations.add(key);
                    } else {
                      _selectedAccommodations.remove(key);
                      if (_selectedAccommodations.isEmpty) {
                        _selectedAccommodations = ['all'];
                      }
                    }
                  }
                });
              },
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range (₹)',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '₹${_minPrice.toInt()}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
            const Spacer(),
            Text(
              '₹${_maxPrice.toInt()}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 50000,
          divisions: 100,
          labels: RangeLabels('₹${_minPrice.toInt()}', '₹${_maxPrice.toInt()}'),
          onChanged: (RangeValues values) {
            setState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildExcludeSection() {
    final excludeTypes = ['Street', 'City', 'State', 'Country'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exclude Search Types',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: excludeTypes.map((type) {
            final key = type.toLowerCase();
            final isSelected = _excludedSearchTypes.contains(key);

            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _excludedSearchTypes.add(key);
                  } else {
                    _excludedSearchTypes.remove(key);
                  }
                });
              },
              selectedColor: Colors.red[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.red[700] : Colors.black87,
                fontSize: 12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Search Hotels',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate : _checkOutDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (_checkInDate.isAfter(_checkOutDate) ||
              _checkInDate.isAtSameMomentAs(_checkOutDate)) {
            _checkOutDate = _checkInDate.add(const Duration(days: 1));
          }
        } else {
          if (picked.isAfter(_checkInDate)) {
            _checkOutDate = picked;
          }
        }
      });
    }
  }

  void _handleSearch() {
    final criteria = SearchCriteria(
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      rooms: _rooms,
      adults: _adults,
      children: _children,
      accommodations: _selectedAccommodations,
      excludedSearchTypes: _excludedSearchTypes,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );

    widget.onSearch(criteria);
    // Navigator.pop(context);
  }
}

class SearchCriteria {
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int rooms;
  final int adults;
  final int children;
  final List<String> accommodations;
  final List<String> excludedSearchTypes;
  final double minPrice;
  final double maxPrice;

  SearchCriteria({
    required this.checkInDate,
    required this.checkOutDate,
    required this.rooms,
    required this.adults,
    required this.children,
    required this.accommodations,
    required this.excludedSearchTypes,
    required this.minPrice,
    required this.maxPrice,
  });

  String get checkIn {
    return '${checkInDate.year}-${checkInDate.month.toString().padLeft(2, '0')}-${checkInDate.day.toString().padLeft(2, '0')}';
  }

  String get checkOut {
    return '${checkOutDate.year}-${checkOutDate.month.toString().padLeft(2, '0')}-${checkOutDate.day.toString().padLeft(2, '0')}';
  }
}
