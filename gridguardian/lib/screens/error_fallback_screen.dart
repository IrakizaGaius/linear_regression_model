import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class ErrorFallbackScreen extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;
  final Logger _logger = Logger();

  ErrorFallbackScreen({
    super.key,
    required this.error,
    this.stackTrace,
  }) {
    _logError();
  }

  void _logError() {
    _logger.e('Critical error occurred', error: error, stackTrace: stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Critical Error'),
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildErrorHeader(),
              const SizedBox(height: 20),
              Expanded(child: _buildErrorDetails()),
              const SizedBox(height: 30),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorDetails() {
    final stackTraceString = stackTrace?.toString() ?? '';
    final trimmedStackTrace = stackTraceString.isEmpty
        ? ''
        : stackTraceString.substring(
            0, stackTraceString.length < 500 ? stackTraceString.length : 500);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Error Details:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          SelectableText(
            error.toString(),
            style: const TextStyle(
              fontFamily: 'monospace',
              color: Colors.red,
            ),
          ),
          if (stackTrace != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Stack Trace:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            SelectableText(
              trimmedStackTrace,
              maxLines: 20, // Required for overflow to work
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.grey,
                overflow: TextOverflow.ellipsis, // Correct placement
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorHeader() {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        const SizedBox(height: 15),
        Text(
          'Application Error',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'The application encountered a critical error during initialization.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy Details'),
            onPressed: () => _copyErrorDetails(context),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: FilledButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Restart App'),
            onPressed: () => SystemNavigator.pop(),
          ),
        ),
      ],
    );
  }

  void _copyErrorDetails(BuildContext context) {
    final details = '''
Error: $error
Stack Trace: ${stackTrace ?? 'Not available'}
''';
    Clipboard.setData(ClipboardData(text: details));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error details copied to clipboard')),
    );
  }
}
