enum ServiceType {
  feedbin('feedbin'),
  theOldReader('theoldreader');

  final String serviceId;
  const ServiceType(this.serviceId);

  String get name {
    switch (this) {
      case ServiceType.feedbin:
        return 'Feedbin';
      case ServiceType.theOldReader:
        return 'The Old Reader';
    }
  }

  String get baseUrl {
    switch (this) {
      case ServiceType.theOldReader:
        return 'https://theoldreader.com/reader/api/0';
      case ServiceType.feedbin:
        return 'https://api.feedbin.me/v2';
    }
  }

  static ServiceType fromString(String value) {
    final normalizedValue = value.toLowerCase();
    return ServiceType.values.firstWhere(
      (type) => type.serviceId.toLowerCase() == normalizedValue,
      orElse: () => ServiceType.theOldReader,
    );
  }
}
