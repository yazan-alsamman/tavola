/// Backend floor-plan `shape` values. Null means the field was absent or
/// not one of the contract shapes.
enum TableShape { circle, rectangle, square, oval }

extension TableShapeApi on TableShape {
  static TableShape? fromApi(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'circle':
      case 'round':
        return TableShape.circle;
      case 'rectangle':
        return TableShape.rectangle;
      case 'square':
        return TableShape.square;
      case 'oval':
      case 'ellipse':
        return TableShape.oval;
      default:
        return null;
    }
  }
}
