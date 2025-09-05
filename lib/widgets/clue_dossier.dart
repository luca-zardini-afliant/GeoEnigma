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
              child: Text(
                isRevealed ? clue.text : '???',
                style: TextStyle(
                  color: isRevealed ? Colors.black : Colors.grey,
                  fontWeight: isRevealed ? FontWeight.normal : FontWeight.bold,
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
}
