//
//  SHH264Decoder.m
//  SmartHome
//
//  Created by ZJ on 2017/4/18.
//  Copyright © 2017年 ZJ. All rights reserved.
//

#import "H264Decoder.h"

@interface H264Decoder () {
    uint8_t *_sps;
    NSInteger _spsSize;
    uint8_t *_pps;
    NSInteger _ppsSize;
    CMVideoFormatDescriptionRef _decoderFormatDescription;
    VTDecompressionSessionRef _deocderSession;
    CVPixelBufferRef _pixelBuffer;
}

@end

static void didDecompress( void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

@implementation H264Decoder

- (BOOL)initH264EnvWithSPSSize:(int)spsSize sps:(const unsigned char *)sps ppsSize:(int)ppsSize pps:(const unsigned char *)pps {
    if (!spsSize || !sps || !ppsSize || !pps) {
        SHLogError(SHLogTagAPP, @"Invalid parameter.");
        return NO;
    }
    
    _spsSize = spsSize - 4;
    _sps = (uint8_t *)malloc(_spsSize);
    memcpy(_sps, sps + 4, _spsSize);

    _ppsSize = ppsSize - 4;
    _pps = (uint8_t *)malloc(_ppsSize);
    memcpy(_pps, pps + 4, _ppsSize);
    
    SHLogInfo(SHLogTagAPP, @"sps:%ld, pps: %ld", (long)_spsSize, (long)_ppsSize);
    
    // test
//    printf("sps: ");
//    for (int i = 0; i < _spsSize; i++) {
//        printf("0x%x ", _sps[i]);
//    }
//    printf("\n");
//
//    printf("pps: ");
//    for (int i = 0; i < _ppsSize; i++) {
//        printf("0x%x ", _pps[i]);
//    }
//    printf("\n");
    
    const uint8_t* const parameterSetPointers[2] = { _sps, _pps };
    const size_t parameterSetSizes[2] = { static_cast<size_t>(_spsSize), static_cast<size_t>(_ppsSize) };
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2, //param count
                                                                          parameterSetPointers,
                                                                          parameterSetSizes,
                                                                          4, //nal start code size
                                                                          &_decoderFormatDescription);
    if(status != noErr) {
        SHLogError(SHLogTagAPP, @"IOS8VT: reset decoder session failed status=%d", (int)status);
        return NO;
    } else {
        CFDictionaryRef attrs = NULL;
        const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
        //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
        //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
        uint32_t v = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
        attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = didDecompress;
        callBackRecord.decompressionOutputRefCon = NULL;
        
        VTDecompressionSessionCreate(kCFAllocatorDefault,
                                     _decoderFormatDescription,
                                     NULL, attrs,
                                     &callBackRecord,
                                     &_deocderSession);
        CFRelease(attrs);
        
        return YES;
    }
}

- (void)clearH264Env {
    if(_deocderSession) {
        VTDecompressionSessionInvalidate(_deocderSession);
        CFRelease(_deocderSession);
        _deocderSession = NULL;
    }
    
    if(_decoderFormatDescription) {
        CFRelease(_decoderFormatDescription);
        _decoderFormatDescription = NULL;
    }
    
    if (_pixelBuffer != nullptr) {
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = nullptr;
    }
    
    free(_sps);
    free(_pps);
    _spsSize = _ppsSize = 0;
}

- (void)decodeAndDisplayH264Frame:(NSData *)frame andAVSLayer:(AVSampleBufferDisplayLayer *)avslayer {
    CMBlockBufferRef blockBuffer = NULL;
    CMSampleBufferRef sampleBuffer = NULL;
    
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                         (void*)frame.bytes, frame.length,
                                                         kCFAllocatorNull,
                                                         NULL, 0, frame.length,
                                                         0, &blockBuffer);
    if(status == kCMBlockBufferNoErr) {
        const size_t sampleSizeArray[] = {frame.length};
        
        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                           blockBuffer,
                                           _decoderFormatDescription,
                                           1, 0, NULL, 1, sampleSizeArray,
                                           &sampleBuffer);
        CFRelease(blockBuffer);
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
        if (status == kCMBlockBufferNoErr) {
            if (avslayer != nil && [avslayer isReadyForMoreMediaData]) {
                dispatch_sync(dispatch_get_main_queue(),^{
                    //flush avslayer when active from background
                    if (avslayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
                        [avslayer flush];
                    }
                    
                    [avslayer enqueueSampleBuffer:sampleBuffer];
                });
            }
            [self recordPixelBufferWithSampleBuffer:sampleBuffer];
            CFRelease(sampleBuffer);
        }
    }
}

- (void)decodeAndDisplayH264Frame:(NSData *)frame displayImageView:(UIImageView *)displayImageView {
    CMBlockBufferRef blockBuffer = NULL;
    CMSampleBufferRef sampleBuffer = NULL;
    CVPixelBufferRef pixelBuffer = NULL;
    
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                         (void*)frame.bytes, frame.length,
                                                         kCFAllocatorNull,
                                                         NULL, 0, frame.length,
                                                         0, &blockBuffer);
    if (status == kCMBlockBufferNoErr) {
        const size_t sampleSizeArray[] = {frame.length};
        
        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                           blockBuffer,
                                           _decoderFormatDescription,
                                           1, 0, NULL, 1, sampleSizeArray,
                                           &sampleBuffer);
        CFRelease(blockBuffer);
        
        if (status == noErr && sampleBuffer) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_deocderSession,
                                                                      sampleBuffer,
                                                                      flags,
                                                                      &pixelBuffer,
                                                                      &flagOut);
            
            CFRelease(sampleBuffer);
            
            if (decodeStatus == kVTInvalidSessionErr) {
                NSLog(@"IOS8VT: Invalid session, reset decoder session");
            } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                NSLog(@"IOS8VT: decode failed status=%d(Bad data)", (int)decodeStatus);
            } else if(decodeStatus != noErr) {
                NSLog(@"IOS8VT: decode failed status=%d", (int)decodeStatus);
            }
            
            if (decodeStatus == noErr && pixelBuffer) {
                UIImage *image = [self imageFromPixelBuffer:pixelBuffer];
                
                if (image != nil) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        displayImageView.image = image;
                    });
                }
            }
            
            CVPixelBufferRelease(pixelBuffer);
        }
    }
}

- (CVPixelBufferRef)pixelBufferFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef outputPixelBuffer = NULL;
    
    if (sampleBuffer) {
        VTDecodeFrameFlags flags = 0;
        VTDecodeInfoFlags flagOut = 0;
        OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_deocderSession,
                                                                  sampleBuffer,
                                                                  flags,
                                                                  &outputPixelBuffer,
                                                                  &flagOut);
        
        if(decodeStatus == kVTInvalidSessionErr) {
            NSLog(@"IOS8VT: Invalid session, reset decoder session");
        } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
            NSLog(@"IOS8VT: decode failed status=%d(Bad data)", (int)decodeStatus);
        } else if(decodeStatus != noErr) {
            NSLog(@"IOS8VT: decode failed status=%d", (int)decodeStatus);
        }
    }
    
    return outputPixelBuffer;
}

- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef imageRef = [context createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return image;
}

- (CVPixelBufferRef)decodeToPixelBufferRef:(NSData*)vp {
    CVPixelBufferRef outputPixelBuffer = NULL;
    
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus status  = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                          (void*)vp.bytes, vp.length,
                                                          kCFAllocatorNull,
                                                          NULL, 0, vp.length,
                                                          0, &blockBuffer);
    if(status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {vp.length};
        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                           blockBuffer,
                                           _decoderFormatDescription ,
                                           1, 0, NULL, 1, sampleSizeArray,
                                           &sampleBuffer);
        if (status == kCMBlockBufferNoErr && sampleBuffer) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_deocderSession,
                                                                      sampleBuffer,
                                                                      flags,
                                                                      &outputPixelBuffer,
                                                                      &flagOut);
            
            if(decodeStatus == kVTInvalidSessionErr) {
                NSLog(@"IOS8VT: Invalid session, reset decoder session");
            } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                NSLog(@"IOS8VT: decode failed status=%d(Bad data)", (int)decodeStatus);
            } else if(decodeStatus != noErr) {
                NSLog(@"IOS8VT: decode failed status=%d", (int)decodeStatus);
            }
            
            CFRelease(sampleBuffer);
        }
        CFRelease(blockBuffer);
    }
    
    return outputPixelBuffer;
}

- (UIImage *)imageFromPixelBufferRef:(NSData *)data {
    CVPixelBufferRef pixelBuffer = [self decodeToPixelBufferRef:data];
    
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer];
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef imageRef = [context createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return image;
}

- (UIImage *)reDrawOrangeImage:(UIImage *)image {
    CGSize size = image.size;
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *drawImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return drawImage;
}

- (NSData *)dataWithYUVPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height  = CVPixelBufferGetHeight(pixelBuffer);
    unsigned char* buffer = (unsigned char*) malloc(width * height * 1.5);
    // 取视频YUV数据
    [self copyDataFromYUVPixelBuffer:pixelBuffer toBuffer:buffer];
    // 保存到本地
    NSData *retData = [NSData dataWithBytes:buffer length:sizeof(unsigned char)*(width*height*1.5)];
    free(buffer);
    buffer = nil;
    return retData;
}

//the size of buffer has to be width * height * 1.5 (yuv)
- (void) copyDataFromYUVPixelBuffer:(CVPixelBufferRef)pixelBuffer toBuffer:(unsigned char*)buffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    if (CVPixelBufferIsPlanar(pixelBuffer)) {
        size_t w = CVPixelBufferGetWidth(pixelBuffer);
        size_t h = CVPixelBufferGetHeight(pixelBuffer);
        
        size_t d = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        unsigned char* src = (unsigned char*) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        unsigned char* dst = buffer;
        
        for (unsigned int rIdx = 0; rIdx < h; ++rIdx, dst += w, src += d) {
            memcpy(dst, src, w);
        }
        
        d = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        src = (unsigned char *) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        
        h = h >> 1;
        for (unsigned int rIdx = 0; rIdx < h; ++rIdx, dst += w, src += d) {
            memcpy(dst, src, w);
        }
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
 
}

char _write = 0;

- (void)recordPixelBufferWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVPixelBufferRef pixelBuffer = [self pixelBufferFromSampleBuffer:sampleBuffer];
    
    if (pixelBuffer == nullptr) {
        return;
    }
    
    @synchronized (self) {
        
        // test
        //======================================================================
        
        if(_write) {
            NSData *yuvData = [self dataWithYUVPixelBuffer:pixelBuffer];
            fwrite(yuvData.bytes , sizeof(char), yuvData.length, self.testfd);
            fflush(self.testfd);
        }
        //======================================================================
        
        
        
        if (_pixelBuffer != nullptr) {
            CVPixelBufferRelease(_pixelBuffer);
            _pixelBuffer = nullptr;
        }
        
        _pixelBuffer = CVPixelBufferRetain(pixelBuffer);
    }
    
    CVPixelBufferRelease(pixelBuffer);
}

- (UIImage *)getCurrentImage {
    CIImage *ciImage = nil;
    CGRect rect = CGRectZero;
    @synchronized (self) {
        if (_pixelBuffer == nullptr) {
            return nil;
        }
        
        ciImage = [[CIImage alloc] initWithCVPixelBuffer:_pixelBuffer];
        rect = CGRectMake(0, 0, CVPixelBufferGetWidth(_pixelBuffer), CVPixelBufferGetHeight(_pixelBuffer));
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef imageRef = [context createCGImage:ciImage fromRect:rect];
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    
    return image;
}

@end
