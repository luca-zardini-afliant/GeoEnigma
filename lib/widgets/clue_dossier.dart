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
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isRevealed ? clue.text : '???',
              style: TextStyle(
                color: isRevealed ? null : Colors.grey,
              ),
            ),
          ),
          if (!isRevealed)
            TextButton(
              onPressed: () => onRevealClue(index),
              child: Text('Reveal (${clue.cost})'),
            ),
        ],
      ),
    );
  }
}
