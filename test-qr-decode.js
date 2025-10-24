// QR Code Image Decoder Test
// This script reads QR code images and decodes them to verify the encoded data

const Jimp = require('jimp');
const jsQR = require('jsqr');
const fs = require('fs');
const path = require('path');

async function decodeQRImage(imagePath) {
    try {
        console.log(`\n📸 Reading image: ${path.basename(imagePath)}`);
        console.log(`   Full path: ${imagePath}`);
        
        // Check if file exists
        if (!fs.existsSync(imagePath)) {
            console.log('   ❌ File not found!');
            return null;
        }
        
        // Read the image
        const image = await Jimp.read(imagePath);
        console.log(`   ✓ Image loaded: ${image.bitmap.width}x${image.bitmap.height} pixels`);
        
        // Get image data
        const imageData = {
            data: new Uint8ClampedArray(image.bitmap.data),
            width: image.bitmap.width,
            height: image.bitmap.height
        };
        
        // Decode QR code
        const code = jsQR(imageData.data, imageData.width, imageData.height);
        
        if (code) {
            console.log('   ✅ QR CODE DECODED SUCCESSFULLY!');
            console.log('   📝 Decoded Data:', code.data);
            console.log('   📍 Location:', {
                topLeft: code.location.topLeftCorner,
                topRight: code.location.topRightCorner,
                bottomLeft: code.location.bottomLeftCorner,
                bottomRight: code.location.bottomRightCorner
            });
            console.log('   ✓ This product code can be scanned!');
            return code.data;
        } else {
            console.log('   ❌ NO QR CODE FOUND in this image');
            console.log('   ⚠️  Possible reasons:');
            console.log('      - Image quality too low');
            console.log('      - Not a valid QR code');
            console.log('      - QR code is corrupted');
            return null;
        }
    } catch (error) {
        console.log(`   ❌ ERROR: ${error.message}`);
        return null;
    }
}

async function testAllQRCodes() {
    console.log('═══════════════════════════════════════════════════');
    console.log('🔍 QR CODE DECODER TEST');
    console.log('═══════════════════════════════════════════════════');
    
    // List of QR code images to test
    const qrImages = [
        'QR_AW112_AtaWa (1).png',
        'QR_aad22344_kfjfjsl (3).png'
    ];
    
    const results = [];
    
    for (const imageName of qrImages) {
        const imagePath = path.join(__dirname, imageName);
        const decodedData = await decodeQRImage(imagePath);
        
        results.push({
            file: imageName,
            decoded: decodedData,
            success: decodedData !== null
        });
    }
    
    // Summary
    console.log('\n═══════════════════════════════════════════════════');
    console.log('📊 TEST SUMMARY');
    console.log('═══════════════════════════════════════════════════');
    
    results.forEach((result, index) => {
        console.log(`\n${index + 1}. ${result.file}`);
        if (result.success) {
            console.log(`   ✅ SUCCESS - Decoded: "${result.decoded}"`);
        } else {
            console.log(`   ❌ FAILED - Could not decode`);
        }
    });
    
    const successCount = results.filter(r => r.success).length;
    const totalCount = results.length;
    
    console.log(`\n📈 Success Rate: ${successCount}/${totalCount} (${Math.round(successCount/totalCount*100)}%)`);
    
    if (successCount === totalCount) {
        console.log('\n✨ ALL QR CODES ARE VALID AND SCANNABLE! ✨');
        console.log('Your QR codes are working correctly.');
        console.log('The scanning issue might be:');
        console.log('  • Laptop camera quality');
        console.log('  • Screen brightness/reflection');
        console.log('  • Distance between camera and screen');
        console.log('\nTry scanning from a printed copy or another device screen.');
    } else if (successCount > 0) {
        console.log('\n⚠️  SOME QR CODES ARE VALID');
        console.log('Check the failed ones - they might need regeneration.');
    } else {
        console.log('\n❌ NO VALID QR CODES FOUND');
        console.log('The QR code generation might have an issue.');
        console.log('Please regenerate the QR codes in inventory.html');
    }
    
    console.log('\n═══════════════════════════════════════════════════\n');
}

// Run the test
testAllQRCodes().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
});
