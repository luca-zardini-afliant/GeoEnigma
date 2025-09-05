import 'package:flutter/material.dart';
import '../models/puzzle_model.dart';

class ClueDossier extends StatelessWidget {
  final List<Clue> clues;
  final List<String> revealedClueIds;
  final Function(int clueIndex) onRevealClue;

  const ClueDossier({
    super.key,
    required this.clues,
    required this.revealedClueIds,
    required this.onRevealClue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dossier',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...clues.asMap().entries.map((entry) => _buildClueItem(context, entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  Widget _buildClueItem(BuildContext context, int index, Clue clue) {
    final isRevealed = revealedClueIds.contains(index.toString());
    
    print('Building clue $index: isRevealed=$isRevealed, text="${clue.text}"');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: isRevealed ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isRevealed ? Colors.green.shade200 : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: isRevealed 
                ? _buildRevealedClue(clue)
                : Text(
                    '???',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
            ),
          ),
          if (!isRevealed)
            GestureDetector(
              onTap: () {
                print('Tapping reveal button for clue $index');
                onRevealClue(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Reveal (${clue.cost})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Revealed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRevealedClue(Clue clue) {
    switch (clue.type) {
      case 'image':
        return _buildImageClue(clue);
      case 'distance':
        return _buildDistanceClue(clue);
      default:
        return _buildTextClue(clue);
    }
  }

  Widget _buildTextClue(Clue clue) {
    return Text(
      clue.text,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.normal,
        fontSize: 14,
      ),
    );
  }

  Widget _buildImageClue(Clue clue) {
    final imageUrl = clue.data?['url'] as String?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          clue.text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
        if (imageUrl != null) ...[
          const SizedBox(height: 8),
          Container(
            height: 50,
            width: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _buildFlagPlaceholder(imageUrl),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFlagPlaceholder(String imageUrl) {
    // Create colored flag placeholders based on the URL
    if (imageUrl.contains('turkey.png')) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE30A17), Color(0xFFFFFFFF)],
            stops: [0.0, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.flag,
            color: Color(0xFFE30A17),
            size: 20,
          ),
        ),
      );
    } else if (imageUrl.contains('france.png')) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002395), Color(0xFFFFFFFF), Color(0xFFED2939)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.flag,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    } else if (imageUrl.contains('australia.png')) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00008B), Color(0xFFFFFFFF), Color(0xFFFF0000)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.flag,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    } else if (imageUrl.contains('uae.png')) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00732F), Color(0xFFFFFFFF), Color(0xFF000000), Color(0xFFFF0000)],
            stops: [0.0, 0.25, 0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.flag,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    } else {
      // Default fallback for other flags
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.flag,
            color: Colors.grey,
            size: 24,
          ),
        ),
      );
    }
  }

  Widget _buildDistanceClue(Clue clue) {
    final fromCity = clue.data?['from_city'] as String?;
    final distance = clue.data?['value_km'] as int?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          clue.text,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
        ),
        if (fromCity != null && distance != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.blue),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    '$distance km from $fromCity',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
