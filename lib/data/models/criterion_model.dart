class CriterionModel {
  final int order;
  final String text;
  final bool required;

  const CriterionModel({
    required this.order,
    required this.text,
    required this.required,
  });

  CriterionModel copyWith({int? order, String? text, bool? required}) {
    return CriterionModel(
      order: order ?? this.order,
      text: text ?? this.text,
      required: required ?? this.required,
    );
  }

  factory CriterionModel.fromMap(Map<String, dynamic> map) {
    return CriterionModel(
      order: map['order'] ?? 0,
      text: map['text'] ?? '',
      required: map['required'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'order': order,
    'text': text,
    'required': required,
  };
}
