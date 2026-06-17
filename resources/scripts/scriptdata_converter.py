import os, struct, json, sys
global sfile, floatOffset, stringOffset, vectorOffset, quaternionOffset, tableOffset, idstringOffset, savedPositions
savedPositions = []
main_dir = "E:\\PAYDAY 2 Modding Workspace\\Files\\"

def main():
    for root, dirs, files in os.walk(main_dir):
        for file in files:
            print(os.path.join(root, file))
            data = decode_scriptdata(os.path.join(root, file))
            print(json.dumps(data, indent=2))

# Scriptdata reading functions (use decode_scriptdata(file))

def read_offset(advance = True):
    global sfile

    if advance:
        sfile.seek(12, os.SEEK_CUR)

    return int.from_bytes(sfile.read(4), byteorder='little', signed = True)

def read_int():
    global sfile

    return int.from_bytes(sfile.read(4), byteorder='little', signed = True)

def read_uint():
    global sfile

    return int.from_bytes(sfile.read(4), byteorder='little', signed = False)

def read_uint64():
    global sfile

    return int.from_bytes(sfile.read(8), byteorder='little', signed = False)

def read_string(index):
    global sfile, stringOffset

    return_string = ""

    seek_push()

    sfile.seek(stringOffset + (index * 8) + 4, os.SEEK_SET)
    real_offset = read_offset(False)

    sfile.seek(real_offset, os.SEEK_SET)
    inchar = sfile.read(1).decode('utf-8', errors='ignore')
    while inchar != '\x00':
        return_string += inchar
        inchar = sfile.read(1).decode('utf-8', errors='ignore')

    seek_pop()

    return return_string

def read_stream_float():
    global sfile

    return struct.unpack('<f', sfile.read(4))[0]

def read_float(index):
    global sfile, floatOffset

    seek_push()

    return_float = 0.0
    sfile.seek(floatOffset + index * 4, os.SEEK_SET)
    return_float = read_stream_float()

    seek_pop()

    return return_float

def read_idstring(index):
    global sfile, idstringOffset

    seek_push()

    return_idstring = 0
    sfile.seek(idstringOffset + (index * 8), os.SEEK_SET)
    return_idstring = read_uint64()

    seek_pop()

    return return_idstring

def read_quaternion(index):
    global sfile, quaternionOffset

    seek_push()

    sfile.seek(quaternionOffset + (index * 16), os.SEEK_SET)
    return_quaternion = []
    return_quaternion.append(read_stream_float())
    return_quaternion.append(read_stream_float())
    return_quaternion.append(read_stream_float())
    return_quaternion.append(read_stream_float())

    seek_pop()

    return return_quaternion

def read_vector(index):
    global sfile, vectorOffset

    seek_push()

    sfile.seek(vectorOffset + (index * 12), os.SEEK_SET)
    return_vector = []
    return_vector.append(read_stream_float())
    return_vector.append(read_stream_float())
    return_vector.append(read_stream_float())

    seek_pop()

    return return_vector

def parse_item():
    item_type = read_uint()
    value = item_type & 0xFFFFFF
    item_type = (item_type >> 24) & 0xFF

    match item_type:
        # Nil
        case 0:
            return None
        # False
        case 1:
            return False
        # True
        case 2:
            return True
        # Number
        case 3:
            return read_float(value)
        # String
        case 4:
            return read_string(value)
        # Vector
        case 5:
            return read_vector(value)
        # Quaternion
        case 6:
            return read_quaternion(value)
        # Idstring
        case 7:
            return read_idstring(value)
        # Table
        case 8:
            return read_table(value)
    
def read_table(index):
    global sfile, tableOffset

    return_table = {}

    seek_push()

    sfile.seek(tableOffset + (index * 20), os.SEEK_SET)

    metatable_offset = read_offset(False)

    item_count = read_int()
    read_int()  # Skip unknown 4 bytes
    items_offset = read_offset(False)

    if metatable_offset >= 0:
        return_table["_meta"] = read_string(metatable_offset)
    for current_item in range(item_count):
        sfile.seek(items_offset + (current_item * 8), os.SEEK_SET)
        key_item = str(parse_item())
        value_item = parse_item()
        return_table[key_item] = value_item

    seek_pop()

    return return_table

def decode_scriptdata(file):
    global sfile, floatOffset, stringOffset, vectorOffset, quaternionOffset, tableOffset, idstringOffset

    with open(file, "rb") as sfile:
        # Read header:
        sfile.seek(0, os.SEEK_SET)

        floatOffset = read_offset()
        stringOffset = read_offset()
        vectorOffset = read_offset()
        quaternionOffset = read_offset()
        idstringOffset = read_offset()
        tableOffset = read_offset()

        sfile.seek(4, os.SEEK_CUR) # 100

        # Parse items:
        try:
            return parse_item() # start from root and recursively parse
        except Exception as e:
            print(f"Error at {sfile.tell()}: {e}")
            sys.exit(1)
    
def seek_push():
    global savedPositions, sfile
    savedPositions.append(sfile.tell())

def seek_pop():
    global savedPositions, sfile
    sfile.seek(savedPositions.pop(), os.SEEK_SET)


if __name__ == "__main__":
    main()