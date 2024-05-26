import 'dart:developer';
import 'dart:io';
import 'package:evitecompanion/config/appstyle.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({super.key});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });

  }

  void onOk() {
    Navigator.of(context).pop(result?.code);
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    // if (Platform.isAndroid) {
    //   controller!.pauseCamera();
    // }
    // controller!.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  Widget onMobile() {
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0
          ),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
        //
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Wrap(
              children: [
                if (result != null)
                  IconButton(
                    onPressed: onOk,
                    color: AppStyle.success,
                    icon: const Icon(Icons.check_circle),
                    tooltip: 'Confirm QR Code',
                  ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  color: AppStyle.error,
                  icon: const Icon(Icons.close),
                  tooltip: 'Scan QR Code',
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  testMobile() {
    return QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
            borderColor: AppStyle.error,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: (MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400) ? 150.0 : 300.0
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: onMobile(),
    );
  }

  @override
  void dispose() {
    result = null;
    qrKey.currentState?.dispose();
    controller?.dispose();
    super.dispose();
  }
}
