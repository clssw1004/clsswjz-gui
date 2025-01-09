class HealthStatus {
  final String status;
  final String timestamp;
  final int uptime;
  final MemoryStatus memory;
  final DatabaseStatus database;

  HealthStatus({
    required this.status,
    required this.timestamp,
    required this.uptime,
    required this.memory,
    required this.database,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
      uptime: json['uptime'] as int,
      memory: MemoryStatus.fromJson(json['memory'] as Map<String, dynamic>),
      database: DatabaseStatus.fromJson(json['database'] as Map<String, dynamic>),
    );
  }
}

class MemoryStatus {
  final String heapUsed;
  final String heapTotal;
  final String rss;

  MemoryStatus({
    required this.heapUsed,
    required this.heapTotal,
    required this.rss,
  });

  factory MemoryStatus.fromJson(Map<String, dynamic> json) {
    return MemoryStatus(
      heapUsed: json['heapUsed'] as String,
      heapTotal: json['heapTotal'] as String,
      rss: json['rss'] as String,
    );
  }
}

class DatabaseStatus {
  final String status;

  DatabaseStatus({required this.status});

  factory DatabaseStatus.fromJson(Map<String, dynamic> json) {
    return DatabaseStatus(
      status: json['status'] as String,
    );
  }
}
