import 'package:flutter/material.dart';

import '../models/fly_information_model.dart';

class FlyInfoCard extends StatefulWidget {
  final FlyInformation flyInfo;

  const FlyInfoCard({
    super.key,
    required this.flyInfo,
  });

  @override
  State<FlyInfoCard> createState() => _FlyInfoCardState();
}

class _FlyInfoCardState extends State<FlyInfoCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'About ${widget.flyInfo.speciesName}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.flyInfo.description,
              style: TextStyle(fontSize: 16),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            firstChild: SizedBox(height: 0),
            secondChild: _buildExpandedContent(),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 300),
          ),

          // Fun fact
          if (widget.flyInfo.funFact.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber.shade800,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fun Fact',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(widget.flyInfo.funFact),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.flyInfo.habitat.isNotEmpty)
            _buildInfoItem(
              icon: Icons.home_outlined,
              title: 'Habitat',
              content: widget.flyInfo.habitat,
            ),

          if (widget.flyInfo.diet.isNotEmpty)
            _buildInfoItem(
              icon: Icons.restaurant_menu,
              title: 'Diet',
              content: widget.flyInfo.diet,
            ),

          if (widget.flyInfo.lifecycle.isNotEmpty)
            _buildInfoItem(
              icon: Icons.autorenew,
              title: 'Lifecycle',
              content: widget.flyInfo.lifecycle,
            ),

          if (widget.flyInfo.significance.isNotEmpty)
            _buildInfoItem(
              icon: Icons.eco_outlined,
              title: 'Significance',
              content: widget.flyInfo.significance,
            ),

          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[700],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(content),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
