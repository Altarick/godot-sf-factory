// Use of FP16 in Godot is done explicitly through the types half and hvec.
// The extensions must be supported by the system to use this shader.

#ifndef AESOS_INC_H
#define AESOS_INC_H


//These extensions are required for the 16 bit manipulation we do (turning floats into flags, because why not)
#extension GL_EXT_shader_explicit_arithmetic_types_float16 : require
#extension GL_EXT_shader_explicit_arithmetic_types_int16 : require
#extension GL_EXT_shader_16bit_storage : require

//returns the uint value of bits between bit_start and bit_end (INCLUSIVE) of the f_value
uint decode_float_16(float f_value,uint bit_start, uint bit_end)
{
    float16_t subf_value = float16_t(f_value);
    uint16_t mask = uint16_t(0u);
    for(int i = 0; i<(1+bit_end)-bit_start;i++ )
    {
        mask = mask << 1u;
        mask |= uint16_t(1u);
    }
    mask = mask << (15u-bit_end);
    uint16_t decoded = halfBitsToUint16(subf_value) & mask;
    decoded = decoded >> (15u-bit_end);
    return uint(decoded);
}

//encodes the rightmost bits of u_value between bit_start and bit_end (INCLUSIVE) in f_value
float encode_float_16(float f_value,uint u_value,uint bit_start, uint bit_end)
{
    float16_t subf_value = float16_t(f_value);
    //mask of ones between bit_start end bit_end inclusive
    uint16_t mask = uint16_t(0u);
    for(int i = 0; i<(1+bit_end)-bit_start;i++ )
    {
        mask = mask << 1u;
        mask |= uint16_t(1u);
    }
    mask = mask << (15u-bit_end);
    //we erase the old data, clear value has zeros where we want ot put new data
    uint16_t clear_value = halfBitsToUint16(subf_value) & (~mask);
    uint16_t encoded = clear_value | (uint16_t(u_value) << (15u-bit_end));
    return float(uint16BitsToHalf(encoded));
}

#endif // AESOS_INC_H
