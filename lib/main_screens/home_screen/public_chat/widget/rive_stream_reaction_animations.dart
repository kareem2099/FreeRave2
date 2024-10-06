import 'package:flutter/material.dart';

const riveStreamReactionAnimations = [
  RiveStreamReaction(
    type: 'love',
    artboard: 'love',
    artboardHighlighted: 'love_highlight',
  ),
  RiveStreamReaction(
    type: 'like',
    artboard: 'like',
    artboardHighlighted: 'like_highlight',
  ),
  RiveStreamReaction(
    type: 'sad',
    artboard: 'sad',
    artboardHighlighted: 'sad_highlight',
  ),
  RiveStreamReaction(
    type: 'haha',
    artboard: 'haha',
    artboardHighlighted: 'haha_highlight',
  ),
  RiveStreamReaction(
    type: 'wow',
    artboard: 'wow',
    artboardHighlighted: 'wow_highlight',
  ),
];

@immutable
class RiveStreamReaction {
  final String type;
  final String artboard;
  final String artboardHighlighted;

  const RiveStreamReaction({
    required this.type,
    required this.artboard,
    required this.artboardHighlighted,
  });
}