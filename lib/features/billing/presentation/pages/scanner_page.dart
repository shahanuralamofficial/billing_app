import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../bloc/billing_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/cart_item.dart';

class ScannerPage extends StatefulWidget {
  final bool isSelectionMode;
  const ScannerPage({super.key, this.isSelectionMode = false});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final MobileScannerController _scannerController;
  bool _isCameraOn = true;
  bool _isFlashOn = false;
  bool _hasPermission = false;

  final Map<String, DateTime> _lastScanTimes = {};

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: [BarcodeFormat.all],
    );
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
    if (_hasPermission) {
      _scannerController.start();
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    final now = DateTime.now();

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final rawValue = barcode.rawValue!;

        // Debounce
        if (_lastScanTimes.containsKey(rawValue)) {
          final lastScan = _lastScanTimes[rawValue]!;
          if (now.difference(lastScan).inSeconds < 2) {
            continue;
          }
        }
        _lastScanTimes[rawValue] = now;

        final canVibrate = await Vibrate.canVibrate;
        if (canVibrate) {
          Vibrate.feedback(FeedbackType.success);
        }

        if (mounted) {
          if (widget.isSelectionMode) {
            // Return the barcode to the previous screen
            context.pop(rawValue);
          } else {
            // Normal billing mode: add to cart
            context.read<BillingBloc>().add(ScanBarcodeEvent(rawValue));
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<BillingBloc, BillingState>(
        listenWhen: (previous, current) =>
            previous.error != current.error && current.error != null,
        listener: (context, state) {
          if (state.error != null && !widget.isSelectionMode) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: widget.isSelectionMode 
                  ? MediaQuery.of(context).size.height 
                  : MediaQuery.of(context).size.height * 0.45,
              child: _buildScannerSection(),
            ),
            if (!widget.isSelectionMode)
              Positioned(
                top: (MediaQuery.of(context).size.height * 0.45) - 24,
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomPanel(),
              ),
          ],
        ),
      ),
      bottomSheet: widget.isSelectionMode 
          ? null 
          : BlocBuilder<BillingBloc, BillingState>(builder: (context, state) {
              return Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: const EdgeInsets.only(bottom: 10),
                child: PrimaryButton(
                  onPressed: state.cartItems.isEmpty
                      ? null
                      : () async {
                          _scannerController.stop();
                          await context.push('/checkout');
                          if (_isCameraOn && mounted) _scannerController.start();
                        },
                  icon: Icons.payment,
                  label: 'Review Order',
                ),
              );
            }),
    );
  }

  Widget _buildScannerSection() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_hasPermission)
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            )
          else
            const Center(child: Text('No Camera Permission', style: TextStyle(color: Colors.white))),
          
          if (!_isCameraOn) _buildCameraOffState(),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: _buildOverlayButton(
              icon: Icons.chevron_left,
              onPressed: () => context.pop(),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Column(
              children: [
                _buildOverlayButton(
                  icon: Icons.settings,
                  onPressed: () async {
                    _scannerController.stop();
                    await context.push('/settings');
                    if (_isCameraOn && mounted) _scannerController.start();
                  },
                ),
                const SizedBox(height: 16),
                if (_isCameraOn)
                  _buildOverlayButton(
                    icon: _isFlashOn ? Icons.flashlight_off : Icons.flashlight_on,
                    onPressed: () {
                      setState(() => _isFlashOn = !_isFlashOn);
                      _scannerController.toggleTorch();
                    },
                  ),
              ],
            ),
          ),

          if (_isCameraOn)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    _buildCorner(Alignment.topLeft),
                    _buildCorner(Alignment.topRight),
                    _buildCorner(Alignment.bottomLeft),
                    _buildCorner(Alignment.bottomRight),
                  ],
                ),
              ),
            ),
          
          if (widget.isSelectionMode)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Scan any barcode to pick it',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraOffState() {
    return Container(
      color: const Color(0xFF1E293B),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF334155),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.videocam_off, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Camera is turned off',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayButton({required IconData icon, required VoidCallback onPressed, Color? color}) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color ?? Colors.black45,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight)
                ? const BorderSide(color: Colors.greenAccent, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, -5))],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          BlocBuilder<BillingBloc, BillingState>(
            builder: (context, state) {
              final totalItems = state.cartItems.fold<int>(0, (sum, i) => sum + i.quantity);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Scanned Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('$totalItems items total', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('TOTAL PRICE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        Text(
                          '৳${state.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<BillingBloc, BillingState>(
              builder: (context, state) {
                if (state.cartItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('List is empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: state.cartItems.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.cartItems[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('৳${item.product.price}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _qtyBtn(Icons.remove, () {
                                if (item.quantity > 1) {
                                  context.read<BillingBloc>().add(UpdateQuantityEvent(item.product.id, item.quantity - 1));
                                } else {
                                  context.read<BillingBloc>().add(RemoveProductFromCartEvent(item.product.id));
                                }
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              _qtyBtn(Icons.add, () {
                                context.read<BillingBloc>().add(UpdateQuantityEvent(item.product.id, item.quantity + 1));
                              }),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
