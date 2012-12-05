{-# LANGUAGE OverloadedStrings #-} 

import Data.Char
import qualified Data.ByteString as B

main = do
  B.writeFile "foo.gif" $ toGif img

ct = realCT `B.append` dummyCT
  where realCT = B.concat $ map B.pack [[r,g,b] | r <- colors, g <- colors, b <- colors]
        dummyCT = B.concat $ replicate 64 $ B.pack [255,0,0]
        colors = [0,64,128,255]

img :: [[(Int,Int,Int)]]
img = take 64 $ repeat [(r,g,b) | r <- [0..3], g <- [0..3], b <- [0..3]]

--toGif img = gif (length $ head img) (length img) imageData
--  where

toGif img = gif w h imageData
  where
    w = length $ head img
    h = length img
    imageData = B.concat $ map mapLines img
    mapLines x = B.concat [bytesToFollow, clear, B.pack $ map (\(r,g,b) -> fromIntegral $ 16*r+4*g+b) x]

    imageEnd = B.concat [smallNumber 1, stop, "\NUL"]
    bytesToFollow = smallNumber $ w + 1
    clear = B.singleton 0x80
    stop  = B.singleton 0x81


gif w h imageData = B.concat
  [ header
  , logicalScreenDescriptor
  , ct
  , imageDescriptor
  , image
  , terminator
  ]
  where -- http://www.onicos.com/staff/iz/formats/gif.html
    header      = "GIF89a"

    logicalScreenDescriptor = B.concat [width, height, gctInfo, bgColor, aspectRatio]
    width       = number w
    height      = number h
    gctInfo     = B.singleton 0xf6
    bgColor     = "\NUL"
    aspectRatio = "\NUL"

    imageDescriptor = B.concat [",", yPos, xPos, width, height, localColor]
    yPos        = number 0
    xPos        = number 0
    localColor  = "\NUL"

    globalColorTable = B.pack [0x08,0x6b,0x52 -- 128 * 3 Bytes
                  ,0x08,0x6b,0x5a,0x10,0x6b,0x5a,0x10,0x73,0x5a,0x10,0x73,0x63,0x18,0x73,0x63,0x18
                  ,0x7b,0x63,0x21,0x7b,0x6b,0x29,0x7b,0x6b,0x29,0x84,0x73,0x52,0xad,0x9c,0x5a,0xb5
                  ,0x9c,0x5a,0xb5,0xa5,0x6b,0xc6,0xad,0x6b,0xc6,0xb5,0x73,0xc6,0xb5,0x73,0xce,0xbd
                  ,0x7b,0xad,0x9c,0x7b,0xce,0xbd,0x7b,0xd6,0xbd,0x7b,0xd6,0xc6,0x84,0xad,0x9c,0x84
                  ,0xb5,0xad,0x84,0xd6,0xc6,0x8c,0xad,0x9c,0x8c,0xb5,0xad,0x8c,0xbd,0xb5,0x8c,0xde
                  ,0xce,0x8c,0xe7,0xd6,0x94,0xb5,0xa5,0x94,0xbd,0xb5,0x9c,0xc6,0xbd,0xb5,0xbd,0xa5
                  ,0xb5,0xbd,0xad,0xbd,0xbd,0xa5,0xbd,0xbd,0xad,0xce,0x63,0x08,0xce,0x6b,0x10,0xce
                  ,0x6b,0x18,0xce,0x73,0x18,0xce,0x73,0x21,0xce,0x73,0x29,0xce,0x7b,0x31,0xce,0x84
                  ,0x39,0xce,0xc6,0xa5,0xd6,0x73,0x18,0xd6,0x73,0x21,0xd6,0x7b,0x29,0xd6,0x7b,0x31
                  ,0xd6,0x84,0x39,0xde,0x7b,0x29,0xde,0x84,0x31,0xde,0x84,0x39,0xde,0x94,0x52,0xde
                  ,0x94,0x5a,0xde,0x9c,0x5a,0xde,0x9c,0x63,0xde,0xa5,0x6b,0xde,0xbd,0x9c,0xe7,0x18
                  ,0x5a,0xe7,0x21,0x63,0xe7,0x29,0x63,0xe7,0x29,0x6b,0xe7,0x31,0x6b,0xe7,0x39,0x73
                  ,0xe7,0x42,0x73,0xe7,0x4a,0x73,0xe7,0x52,0x73,0xe7,0x52,0x7b,0xe7,0x5a,0x7b,0xe7
                  ,0x8c,0x39,0xe7,0x8c,0x42,0xe7,0x94,0x42,0xe7,0xad,0x7b,0xe7,0xb5,0x84,0xe7,0xb5
                  ,0x8c,0xe7,0xbd,0x8c,0xe7,0xbd,0x94,0xef,0x39,0x73,0xef,0x39,0x7b,0xef,0x42,0x7b
                  ,0xef,0x4a,0x84,0xef,0x52,0x84,0xef,0x84,0xa5,0xef,0x8c,0xad,0xef,0x94,0x4a,0xef
                  ,0x9c,0x4a,0xef,0x9c,0x52,0xef,0xad,0xad,0xef,0xb5,0xad,0xef,0xbd,0x94,0xef,0xbd
                  ,0x9c,0xef,0xc6,0xa5,0xef,0xce,0xad,0xef,0xce,0xb5,0xef,0xd6,0xb5,0xf7,0x4a,0x84
                  ,0xf7,0x52,0x84,0xf7,0x52,0x8c,0xf7,0x5a,0x8c,0xf7,0x5a,0x94,0xf7,0x63,0x94,0xf7
                  ,0x8c,0xad,0xf7,0x94,0xb5,0xf7,0x9c,0xb5,0xf7,0x9c,0xbd,0xf7,0xa5,0x5a,0xf7,0xa5
                  ,0x63,0xf7,0xa5,0xc6,0xf7,0xad,0x63,0xf7,0xad,0xc6,0xf7,0xb5,0xce,0xf7,0xbd,0xce
                  ,0xf7,0xbd,0xd6,0xf7,0xc6,0xd6,0xf7,0xd6,0xbd,0xf7,0xe7,0xce,0xff,0x6b,0x9c,0xff
                  ,0xad,0x6b,0xff,0xb5,0x6b,0xff,0xb5,0x73,0xff,0xd6,0xde,0xff,0xef,0xe7,0xff,0xff
                  ,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff]

    image = B.concat [lzwMinSize, imageData]
    lzwMinSize = B.singleton 0x07
    imageData2 = B.pack
      [0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x6e,0x67,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x54,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x6e,0x3b,0x54,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x54,0x3b,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x6e,0x3f,0x3e,0x67,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7a,0x39,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x39,0x7a,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x67,0x3e,0x3f,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x40,0x65,0x3f,0x54,0x7b,0x7b,0x7b,0x7b,0x7b,0x7a,0x25,0x38,0x7b,0x7b
      ,0x7b,0x7b,0x7b,0x7b,0x38,0x25,0x7a,0x7b,0x7b,0x7b,0x7b,0x7b,0x54,0x3f,0x65,0x40
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x40,0x75,0x65,0x3e,0x68,0x7b,0x7b,0x7b,0x7b,0x7a,0x26,0x2f,0x38,0x7b
      ,0x7b,0x7b,0x7b,0x38,0x2f,0x26,0x7a,0x7b,0x7b,0x7b,0x7b,0x68,0x3e,0x65,0x75,0x40
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x40,0x75,0x75,0x62,0x41,0x4d,0x7b,0x7b,0x7b,0x7a,0x28,0x78,0x30,0x36
      ,0x7b,0x7b,0x36,0x30,0x78,0x28,0x7a,0x7b,0x7b,0x7b,0x4d,0x41,0x62,0x75,0x75,0x40
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x40,0x75,0x75,0x63,0x41,0x25,0x4b,0x7b,0x7b,0x7a,0x28,0x78,0x78,0x2f
      ,0x38,0x38,0x2f,0x78,0x78,0x28,0x7a,0x7b,0x7b,0x4b,0x25,0x41,0x63,0x75,0x75,0x40
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x68,0x67,0x67,0x67,0x67,0x67
      ,0x67,0x6c,0x3d,0x52,0x75,0x63,0x41,0x28,0x28,0x4b,0x7b,0x7a,0x28,0x78,0x78,0x76
      ,0x25,0x25,0x76,0x78,0x78,0x28,0x7a,0x7b,0x4b,0x28,0x28,0x41,0x63,0x75,0x52,0x3d
      ,0x6c,0x67,0x67,0x67,0x67,0x67,0x67,0x68,0x2f,0x80,0x70,0x3b,0x3f,0x41,0x41,0x41
      ,0x41,0x3d,0x68,0x3e,0x52,0x63,0x41,0x2f,0x76,0x2e,0x49,0x7a,0x26,0x78,0x78,0x78
      ,0x25,0x25,0x78,0x78,0x78,0x26,0x7a,0x49,0x2e,0x76,0x2f,0x41,0x63,0x52,0x3e,0x68
      ,0x3d,0x41,0x41,0x41,0x41,0x3f,0x3b,0x70,0x2f,0x80,0x7b,0x70,0x3d,0x63,0x75,0x75
      ,0x75,0x64,0x3d,0x54,0x3d,0x41,0x41,0x2f,0x78,0x6d,0x28,0x4a,0x2f,0x47,0x78,0x78
      ,0x25,0x25,0x78,0x78,0x47,0x2f,0x4a,0x28,0x6d,0x78,0x2f,0x41,0x41,0x3d,0x54,0x3d
      ,0x64,0x75,0x75,0x75,0x63,0x3d,0x70,0x7b,0x2f,0x80,0x7b,0x7b,0x70,0x3d,0x63,0x75
      ,0x75,0x75,0x63,0x3d,0x54,0x3d,0x41,0x2f,0x78,0x78,0x6b,0x28,0x18,0x30,0x47,0x78
      ,0x25,0x25,0x78,0x47,0x30,0x18,0x28,0x6b,0x78,0x78,0x2f,0x41,0x3d,0x54,0x3d,0x63
      ,0x75,0x75,0x75,0x63,0x3c,0x70,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x6f,0x3d,0x51
      ,0x52,0x52,0x52,0x50,0x3b,0x68,0x44,0x2f,0x78,0x78,0x6d,0x28,0x01,0x18,0x2a,0x47
      ,0x25,0x25,0x47,0x2a,0x18,0x01,0x28,0x6d,0x78,0x78,0x2f,0x44,0x68,0x3b,0x50,0x52
      ,0x52,0x52,0x51,0x3d,0x6f,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x6f,0x44
      ,0x43,0x43,0x43,0x43,0x43,0x45,0x59,0x28,0x57,0x78,0x6d,0x28,0x04,0x07,0x18,0x2a
      ,0x25,0x25,0x2a,0x18,0x07,0x04,0x28,0x6d,0x78,0x57,0x28,0x59,0x45,0x43,0x43,0x43
      ,0x43,0x43,0x44,0x6f,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x5e
      ,0x25,0x2e,0x34,0x34,0x34,0x34,0x26,0x4d,0x28,0x57,0x6d,0x28,0x05,0x17,0x07,0x18
      ,0x2a,0x2a,0x18,0x07,0x17,0x05,0x28,0x6d,0x55,0x28,0x4d,0x26,0x34,0x34,0x34,0x34
      ,0x2e,0x25,0x5e,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x5f,0x26,0x6a,0x78,0x78,0x78,0x6b,0x26,0x4b,0x28,0x47,0x28,0x05,0x1b,0x14,0x07
      ,0x1d,0x1d,0x07,0x14,0x1b,0x05,0x28,0x47,0x28,0x4b,0x26,0x6b,0x78,0x78,0x78,0x6a
      ,0x26,0x73,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x73,0x26,0x6a,0x78,0x78,0x78,0x6b,0x28,0x4a,0x26,0x28,0x05,0x1b,0x1b,0x12
      ,0x01,0x01,0x12,0x1b,0x1b,0x05,0x28,0x26,0x4b,0x28,0x6b,0x78,0x78,0x78,0x6a,0x26
      ,0x73,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x7b,0x5e,0x26,0x57,0x57,0x57,0x57,0x47,0x25,0x4c,0x2a,0x05,0x1b,0x1b,0x1b
      ,0x01,0x01,0x1b,0x1b,0x1b,0x05,0x2a,0x4b,0x25,0x47,0x57,0x57,0x57,0x57,0x26,0x5e
      ,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x74,0x74,0x74,0x74
      ,0x74,0x74,0x74,0x5c,0x2a,0x2a,0x2a,0x2a,0x2a,0x2a,0x2b,0x2c,0x05,0x0c,0x1b,0x1b
      ,0x01,0x01,0x1b,0x1b,0x0c,0x05,0x2c,0x2b,0x2a,0x2a,0x2a,0x2a,0x2a,0x2a,0x5c,0x74
      ,0x74,0x74,0x74,0x74,0x74,0x74,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x4a,0x25,0x28,0x2f
      ,0x2f,0x2f,0x2f,0x28,0x20,0x02,0x05,0x09,0x09,0x09,0x09,0x05,0x1f,0x07,0x0b,0x1b
      ,0x01,0x01,0x1b,0x0b,0x07,0x1f,0x05,0x09,0x09,0x09,0x09,0x05,0x02,0x20,0x28,0x2f
      ,0x2f,0x2f,0x2f,0x28,0x25,0x4a,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x4b,0x28,0x6d
      ,0x78,0x78,0x78,0x57,0x26,0x22,0x05,0x0e,0x1b,0x1b,0x1b,0x0f,0x05,0x1a,0x06,0x0a
      ,0x01,0x01,0x0a,0x06,0x1a,0x05,0x0f,0x1b,0x1b,0x1b,0x0e,0x05,0x22,0x26,0x57,0x78
      ,0x78,0x78,0x6d,0x28,0x4d,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x4d,0x28
      ,0x6d,0x78,0x78,0x78,0x57,0x27,0x22,0x05,0x0e,0x1b,0x1b,0x1b,0x0f,0x05,0x19,0x05
      ,0x01,0x01,0x05,0x19,0x05,0x0f,0x1b,0x1b,0x1b,0x0d,0x05,0x22,0x27,0x57,0x78,0x78
      ,0x78,0x6d,0x28,0x4d,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x4b
      ,0x28,0x6b,0x6d,0x6d,0x6d,0x47,0x26,0x20,0x05,0x0d,0x12,0x12,0x12,0x0c,0x02,0x1a
      ,0x05,0x05,0x1a,0x02,0x0c,0x12,0x12,0x12,0x0d,0x05,0x20,0x26,0x47,0x6d,0x6d,0x6d
      ,0x6b,0x28,0x4b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x4b,0x28,0x28,0x28,0x28,0x28,0x28,0x31,0x20,0x07,0x07,0x07,0x07,0x07,0x07,0x08
      ,0x1e,0x1e,0x08,0x07,0x07,0x07,0x07,0x07,0x07,0x20,0x31,0x28,0x28,0x28,0x28,0x28
      ,0x28,0x4b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x37,0x26,0x26,0x26,0x26,0x26,0x25,0x31,0x18,0x02,0x05,0x05,0x05,0x05,0x01,0x05
      ,0x1e,0x1e,0x05,0x01,0x05,0x05,0x05,0x05,0x02,0x18,0x31,0x25,0x26,0x26,0x26,0x26
      ,0x26,0x37,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x35
      ,0x33,0x78,0x78,0x78,0x78,0x47,0x31,0x11,0x07,0x17,0x1b,0x1b,0x1b,0x0b,0x07,0x1f
      ,0x02,0x02,0x1f,0x07,0x0b,0x1b,0x1b,0x1b,0x17,0x07,0x11,0x31,0x47,0x78,0x78,0x78
      ,0x78,0x33,0x35,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x36,0x33
      ,0x78,0x78,0x78,0x78,0x47,0x31,0x15,0x07,0x17,0x1b,0x1b,0x1b,0x0b,0x07,0x1f,0x05
      ,0x01,0x01,0x05,0x1f,0x06,0x0b,0x1b,0x1b,0x1b,0x17,0x07,0x15,0x30,0x47,0x78,0x78
      ,0x78,0x78,0x30,0x36,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x36,0x30,0x78
      ,0x78,0x78,0x78,0x47,0x30,0x18,0x07,0x17,0x1b,0x1b,0x1b,0x0c,0x07,0x1a,0x05,0x0f
      ,0x01,0x01,0x0f,0x05,0x1a,0x07,0x0c,0x1b,0x1b,0x1b,0x17,0x07,0x18,0x30,0x47,0x78
      ,0x78,0x78,0x78,0x30,0x36,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x39,0x25,0x25,0x25
      ,0x25,0x25,0x25,0x2a,0x1d,0x01,0x01,0x01,0x01,0x01,0x01,0x05,0x16,0x05,0x0f,0x1b
      ,0x01,0x01,0x1b,0x0f,0x05,0x16,0x05,0x01,0x01,0x01,0x01,0x01,0x01,0x1d,0x2a,0x25
      ,0x25,0x25,0x25,0x25,0x25,0x39,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x7b,0x7b,0x4b,0x25,0x25,0x25,0x25,0x25,0x25,0x28,0x3a,0x03,0x0f,0x1b,0x1b
      ,0x01,0x01,0x1b,0x1b,0x0f,0x03,0x3a,0x28,0x25,0x25,0x25,0x25,0x25,0x25,0x4b,0x7b
      ,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x7b,0x49,0x2e,0x76,0x78,0x78,0x78,0x55,0x28,0x4d,0x29,0x05,0x1b,0x1b,0x1b
      ,0x01,0x01,0x1b,0x1b,0x1b,0x05,0x29,0x4d,0x28,0x55,0x78,0x78,0x78,0x76,0x2e,0x49
      ,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x49,0x2f,0x76,0x78,0x78,0x78,0x55,0x28,0x4d,0x25,0x28,0x05,0x1b,0x1b,0x0f
      ,0x02,0x02,0x0f,0x1b,0x1b,0x05,0x28,0x25,0x4d,0x28,0x55,0x78,0x78,0x78,0x76,0x2f
      ,0x49,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x49,0x2f,0x76,0x78,0x78,0x78,0x55,0x28,0x4b,0x26,0x57,0x28,0x05,0x1b,0x0e,0x05
      ,0x22,0x22,0x05,0x0e,0x1b,0x05,0x28,0x57,0x26,0x4d,0x28,0x55,0x78,0x78,0x78,0x76
      ,0x2f,0x49,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x4b
      ,0x25,0x25,0x26,0x26,0x26,0x26,0x28,0x4b,0x26,0x6b,0x6d,0x28,0x05,0x0d,0x05,0x22
      ,0x28,0x28,0x22,0x05,0x0e,0x05,0x28,0x6d,0x6b,0x26,0x4b,0x28,0x26,0x26,0x26,0x26
      ,0x25,0x25,0x4b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x67,0x3f
      ,0x3f,0x3f,0x3f,0x3f,0x3f,0x41,0x58,0x26,0x6a,0x78,0x6d,0x28,0x02,0x05,0x20,0x26
      ,0x25,0x25,0x28,0x20,0x05,0x02,0x28,0x6d,0x78,0x6a,0x26,0x58,0x41,0x3f,0x3f,0x3f
      ,0x3f,0x3f,0x3f,0x67,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x54,0x3d,0x63
      ,0x65,0x65,0x65,0x50,0x3d,0x67,0x42,0x2f,0x78,0x78,0x6d,0x28,0x02,0x20,0x28,0x57
      ,0x25,0x25,0x57,0x26,0x20,0x02,0x28,0x6d,0x78,0x78,0x2f,0x42,0x67,0x3d,0x50,0x65
      ,0x65,0x65,0x63,0x3d,0x54,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x53,0x3e,0x65,0x75
      ,0x75,0x75,0x51,0x3e,0x69,0x3c,0x41,0x2f,0x78,0x78,0x57,0x28,0x20,0x26,0x57,0x78
      ,0x25,0x25,0x78,0x57,0x26,0x20,0x28,0x57,0x78,0x78,0x2f,0x41,0x3c,0x68,0x3d,0x51
      ,0x75,0x75,0x75,0x65,0x3e,0x54,0x7b,0x7b,0x2f,0x80,0x7b,0x53,0x3f,0x65,0x75,0x75
      ,0x75,0x51,0x3e,0x67,0x3d,0x51,0x41,0x2f,0x78,0x6a,0x26,0x5e,0x28,0x57,0x78,0x78
      ,0x25,0x25,0x78,0x78,0x57,0x28,0x5e,0x26,0x6a,0x78,0x2f,0x41,0x51,0x3d,0x67,0x3e
      ,0x51,0x75,0x75,0x75,0x65,0x3f,0x53,0x7b,0x2f,0x80,0x54,0x3b,0x3d,0x3f,0x3f,0x3f
      ,0x3f,0x3d,0x67,0x3d,0x64,0x63,0x41,0x2f,0x6a,0x26,0x73,0x7a,0x28,0x78,0x78,0x78
      ,0x25,0x25,0x78,0x78,0x78,0x28,0x7a,0x73,0x26,0x6a,0x2f,0x41,0x63,0x63,0x3d,0x67
      ,0x3d,0x3f,0x3f,0x3f,0x3f,0x3d,0x3b,0x67,0x2f,0x80,0x79,0x79,0x79,0x79,0x79,0x79
      ,0x79,0x70,0x3d,0x63,0x75,0x63,0x41,0x26,0x26,0x5e,0x7b,0x7a,0x28,0x78,0x78,0x6b
      ,0x25,0x25,0x6d,0x78,0x78,0x28,0x7a,0x7b,0x5e,0x26,0x26,0x41,0x63,0x75,0x63,0x3d
      ,0x70,0x79,0x79,0x79,0x79,0x79,0x79,0x79,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x40,0x75,0x75,0x63,0x41,0x25,0x5d,0x7b,0x7b,0x7a,0x28,0x78,0x6d,0x28
      ,0x4b,0x4b,0x28,0x6d,0x78,0x28,0x7a,0x7b,0x7b,0x5d,0x25,0x41,0x63,0x75,0x75,0x40
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x40,0x75,0x75,0x52,0x41,0x5d,0x7b,0x7b,0x7b,0x7a,0x28,0x6d,0x28,0x4d
      ,0x7b,0x7b,0x4d,0x28,0x6d,0x28,0x7a,0x7b,0x7b,0x7b,0x5d,0x41,0x52,0x75,0x75,0x40
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x40,0x75,0x63,0x3d,0x6f,0x7b,0x7b,0x7b,0x7b,0x7a,0x26,0x28,0x4b,0x7b
      ,0x7b,0x7b,0x7b,0x4b,0x28,0x26,0x7a,0x7b,0x7b,0x7b,0x7b,0x6f,0x3d,0x63,0x75,0x40
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x40,0x63,0x3c,0x70,0x7b,0x7b,0x7b,0x7b,0x7b,0x7a,0x25,0x4a,0x7b,0x7b
      ,0x7b,0x7b,0x7b,0x7b,0x4a,0x25,0x7a,0x7b,0x7b,0x7b,0x7b,0x7b,0x70,0x3c,0x63,0x40
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x3e,0x3d,0x6f,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7a,0x4b,0x7b,0x7b,0x7b
      ,0x7b,0x7b,0x7b,0x7b,0x7b,0x4a,0x7a,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x6f,0x3d,0x3e
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6e,0x3c,0x6f,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x6f,0x3c
      ,0x6e,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x2f,0x80,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x6f,0x70,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b
      ,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x70
      ,0x6f,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x7b,0x01,0x81,0x00
      ]

    terminator  = ";"

smallNumber x = B.singleton $ fromIntegral $ x `mod` 256
number x = B.pack $ map fromIntegral [x `mod` 256, x `div` 256]

