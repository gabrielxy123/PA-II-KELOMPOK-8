import 'package:flutter/material.dart';

class BannerCarouselWidget extends StatefulWidget {
  final PageController pageController;
  final int currentBannerIndex;
  final Function(int) onPageChanged;

  const BannerCarouselWidget({
    Key? key,
    required this.pageController,
    required this.currentBannerIndex,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  State<BannerCarouselWidget> createState() => _BannerCarouselWidgetState();
}

class _BannerCarouselWidgetState extends State<BannerCarouselWidget> {
  // List of images
  final List<String> bannerImages = [
    'assets/images/logo.png',
    'assets/images/agian.png',
    'assets/images/fanya.png',
    'assets/images/logo.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner
        Container(
          height: 120,
          margin: const EdgeInsets.only(top: 16),
          child: PageView.builder(
            controller: widget.pageController,
            onPageChanged: widget.onPageChanged,
            itemCount: bannerImages.length, // Use the length of the list
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(bannerImages[index]), // Load image by index
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        // Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length, // Use the length of the list
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.currentBannerIndex == index ? Colors.teal : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
