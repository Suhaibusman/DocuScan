import 'dart:convert';

enum DocumentStatus {
  scanning,
  processed,
  exported,
}

enum FilterType {
  none,
  grayscale,
  blackWhite,
  enhanced,
}

class DocumentModel {
  final String id;
  final String name;
  final List<String> imagePaths;
  final String? pdfPath;
  final String? extractedText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DocumentStatus status;
  final FilterType appliedFilter;
  final List<String> tags;

  DocumentModel({
    required this.id,
    required this.name,
    required this.imagePaths,
    this.pdfPath,
    this.extractedText,
    required this.createdAt,
    required this.updatedAt,
    this.status = DocumentStatus.processed,
    this.appliedFilter = FilterType.none,
    this.tags = const [],
  });

  int get pageCount => imagePaths.length;
  bool get hasPdf => pdfPath != null && pdfPath!.isNotEmpty;
  bool get hasText => extractedText != null && extractedText!.isNotEmpty;

  DocumentModel copyWith({
    String? id,
    String? name,
    List<String>? imagePaths,
    String? pdfPath,
    String? extractedText,
    DateTime? createdAt,
    DateTime? updatedAt,
    DocumentStatus? status,
    FilterType? appliedFilter,
    List<String>? tags,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePaths: imagePaths ?? this.imagePaths,
      pdfPath: pdfPath ?? this.pdfPath,
      extractedText: extractedText ?? this.extractedText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      appliedFilter: appliedFilter ?? this.appliedFilter,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePaths': imagePaths,
      'pdfPath': pdfPath,
      'extractedText': extractedText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status.name,
      'appliedFilter': appliedFilter.name,
      'tags': tags,
    };
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      name: json['name'],
      imagePaths: List<String>.from(json['imagePaths']),
      pdfPath: json['pdfPath'],
      extractedText: json['extractedText'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DocumentStatus.processed,
      ),
      appliedFilter: FilterType.values.firstWhere(
        (e) => e.name == json['appliedFilter'],
        orElse: () => FilterType.none,
      ),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory DocumentModel.fromJsonString(String jsonString) {
    return DocumentModel.fromJson(jsonDecode(jsonString));
  }
}