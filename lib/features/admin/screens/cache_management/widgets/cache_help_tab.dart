import 'package:flutter/material.dart';
import 'package:traqtrace_app/core/config/app_assets.dart';
import 'package:traqtrace_app/core/config/nav_icons.dart';
import 'package:traqtrace_app/core/utils/app_color_mapper.dart';
import 'package:traqtrace_app/core/widgets/traq_icon.dart';
import 'package:traqtrace_app/features/admin/screens/cache_management/widgets/cache_help_section.dart';

class CacheHelpTab extends StatelessWidget {
  const CacheHelpTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColorMapper.infoColor(context), AppColorMapper.infoColor(context)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TraqIcon(AppAssets.iconRefresh, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        'TraqTrace Cache Management System',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phase 3.2 Caching Layer - Comprehensive Performance Optimization',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          CacheHelpSection(
            'System Overview',
            AppAssets.iconArchitecture,
            AppColorMapper.infoColor(context),
            [
              'The TraqTrace caching system implements a multi-tier caching strategy designed to optimize performance for pharmaceutical track and trace operations.',
              'Our implementation uses Redis as the distributed cache backend with Spring Cache annotations for seamless integration.',
              'The system provides automatic cache management, real-time monitoring, and intelligent eviction policies.',
            ],
          ),

          const SizedBox(height: 16),

          CacheHelpSection(
            'Cache Types Implemented',
            AppAssets.iconLayers,
            AppColorMapper.successColor(context),
            [
              '🔵 Query Results Cache (15-minute TTL): Stores complex EPCIS query results for fast retrieval',
              '🟡 Master Data Cache (1-hour TTL): Caches GS1 identifiers (GTIN, GLN, SSCC, SGTIN) and validation rules',
              '🔴 Hot Data Cache (30-minute TTL): Stores recent EPCIS events (Object, Aggregation, Transaction, Transformation)',
              '🟣 Distributed Cache: Enables cache synchronization across multiple application instances',
            ],
          ),

          const SizedBox(height: 16),

          CacheHelpSection(
            'Technical Implementation',
            AppAssets.iconCode,
            AppColorMapper.warningColor(context),
            [
              '• Spring Cache Integration: @Cacheable, @CacheEvict, and @CachePut annotations',
              '• Redis Backend: Lettuce connection factory with connection pooling',
              '• Serialization: JSON serialization for complex objects',
              '• Key Strategy: Unique cache keys per service and identifier type',
              '• TTL Management: Time-based expiration with configurable durations',
              '• Eviction Policy: LRU (Least Recently Used) for optimal memory usage',
            ],
          ),

          const SizedBox(height: 16),

          CacheHelpSection(
            'Cached Services Coverage',
            AppAssets.iconSettings,
            AppColorMapper.chartColor(context, 5),
            [
              '✅ GS1 Identifier Services: GTIN, GLN, SSCC, SGTIN services',
              '✅ EPCIS Event Services: Object, Aggregation, Transaction, Transformation events',
              '✅ Advanced Query Service: Complex multi-criteria searches',
              '✅ Validation Rules: Business rule validation caching',
              '✅ Trading Partners: Supply chain partner information',
            ],
          ),

          const SizedBox(height: 16),

          CacheHelpSection(
            'Development Environment (Current)',
            AppAssets.iconComputer,
            AppColorMapper.chartColor(context, 3),
            [
              '🐳 Docker Redis (required for default backend profile)',
              '   • Image: redis:7-alpine (see backend/docker-compose.yml)',
              '   • Port: 6379 (localhost)',
              '   • Password: None (development only)',
              '',
              '🚀 Quick setup (TraqTrace repository):',
              '   1. Install Docker Desktop',
              '   2. Run: docker compose -f backend/docker-compose.yml up -d redis',
              '      (or: cd backend && docker compose up -d redis)',
              '   3. Verify: docker compose -f backend/docker-compose.yml ps',
              '      or   docker exec traqtrace-redis redis-cli ping',
              '   4. Stop: docker compose -f backend/docker-compose.yml stop redis',
              '   5. Start: docker compose -f backend/docker-compose.yml start redis',
              '',
              '⚙️ Application configuration (Spring Boot 3):',
              '   • spring.data.redis.host=localhost',
              '   • spring.data.redis.port=6379',
              '   • spring.cache.type=redis (default; use SPRING_CACHE_TYPE=simple if Redis is off)',
              '',
              '❗ Note: Redis must be running for distributed cache; health shows redis component when UP',
            ],
          ),

          const SizedBox(height: 16),

          CacheHelpSection(
            'Production Environment (Azure)',
            AppAssets.iconCloud,
            AppColorMapper.chartColor(context, 4),
            [
              '☁️ Azure Redis Cache (Managed Service)',
              '   • Tier: Standard (Primary + Replica)',
              '   • SLA: 99.9% uptime guarantee',
              '   • Port: 6380 (SSL enabled)',
              '   • Features: Automatic backup, scaling, monitoring',
              '',
              '🔐 Security Features:',
              '   • SSL/TLS encryption in transit',
              '   • VNet integration for private access',
              '   • Access key rotation',
              '   • Azure Active Directory integration',
              '',
              '📊 Monitoring Integration:',
              '   • Azure Monitor integration',
              '   • Application Insights correlation',
              '   • Custom metrics and alerts',
            ],
          ),

          const SizedBox(height: 16),

          CacheHelpSection(
            'Performance Benefits',
            NavIcons.performanceOptimization,
            AppColorMapper.errorColor(context),
            [
              '🚀 Response Time Reduction: Up to 90% faster for cached queries',
              '💾 Database Load Reduction: Significant decrease in PostgreSQL queries',
              '📈 Scalability Improvement: Better handling of concurrent requests',
              '🔄 Distributed Performance: Cache sharing across application instances',
              '⚡ Hot Data Access: Near-instant retrieval of recent events',
            ],
          ),

          const SizedBox(height: 16),

          CacheHelpSection(
            'Available Management Operations',
            AppAssets.iconSecurity,
            AppColorMapper.chartColor(context, 0),
            [
              '🔄 Cache Warm-up: Pre-populate cache with frequently accessed data',
              '🧹 Selective Clearing: Clear specific cache types (Master Data, Hot Data, Query Results)',
              '📊 Real-time Statistics: Monitor hit ratios, cache sizes, and performance metrics',
              '🏥 Health Monitoring: Track cache system health and connectivity',
              '⚠️ Emergency Clear: Complete cache reset (use with caution)',
              '🔍 Cache Inspection: Detailed view of cache contents and metadata',
            ],
          ),

          const SizedBox(height: 16),

          CacheHelpSection(
            'Best Practices & Guidelines',
            AppAssets.iconThumbUp,
            AppColorMapper.successColor(context),
            [
              '• Monitor cache hit ratios regularly (target: >80%)',
              '• Use cache warm-up after deployments',
              '• Clear caches selectively rather than full clears',
              '• Monitor memory usage and adjust TTL as needed',
              '• Use the Health tab to verify Redis connectivity',
              '• In production, rely on Azure Redis Cache monitoring',
              '• Test cache behavior in staging before production',
            ],
          ),

          const SizedBox(height: 16),

          CacheHelpSection(
            'Troubleshooting Common Issues',
            AppAssets.iconBug,
            AppColorMapper.errorColor(context),
            [
              '🔥 "Unable to connect to Redis" or cache health DOWN:',
              '   1. Check container: docker compose ps   or   docker ps --filter name=traqtrace-redis',
              '   2. Start: docker compose -f backend/docker-compose.yml up -d redis',
              '   3. Verify port 6379 is not blocked',
              '   4. Check spring.data.redis.* and REDIS_* env / application.properties',
              '   5. Temporary fallback: SPRING_CACHE_TYPE=simple (in-process cache only)',
              '',
              '⚡ Poor Cache Performance:',
              '   • Check hit ratios in Statistics tab',
              '   • Consider increasing TTL values',
              '   • Use cache warm-up for frequently accessed data',
              '',
              '💾 Memory Issues:',
              '   • Monitor cache sizes in Overview tab',
              '   • Adjust max-size limits in configuration',
              '   • Clear unused caches periodically',
              '',
              '🔄 Production Deployment:',
              '   • Ensure Azure Redis Cache is provisioned',
              '   • Update connection strings in environment variables',
              '   • Test connectivity before deployment',
            ],
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                TraqIcon(AppAssets.iconInfo, color: AppColorMapper.infoColor(context), size: 24),
                const SizedBox(height: 8),
                Text(
                  'Cache Management System v3.2',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Implemented as part of Phase 3.2 - Performance Optimization Layer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
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