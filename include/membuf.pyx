# Creates a memoryview from a malloced C pointer,
# which will be freed when the python object is garbage collected.
# Code found here is derived from
# http://stackoverflow.com/a/28166272/428751
from cpython.buffer cimport PyBuffer_FillInfo
from libc.stdlib cimport free

# this is the function used to create a memory view from
# a raw pointer.
# Only this function is intended to be used from external
# cython code.
cdef memview_fromptr(void *memory, size_t size):
    # memory is malloced void pointer, size is number of bytes allocated
    if memory==NULL:
        raise MemoryError('no memory allocated to pointer')
    return memoryview( MemBuf_init(memory, size) )

cdef class _MemBuf:
    cdef const void *memory
    cdef size_t size
    def __getbuffer__(self, Py_buffer *buf, int flags):
        PyBuffer_FillInfo(buf, self, <void *>self.memory, self.size, 1, flags)
    def __releasebuffer__(self, Py_buffer *buf):
        # why doesn't this do anything??
        pass
    def __dealloc__(self):
        free(self.memory)

# Call this instead of constructing a _MemBuf directly.  The __cinit__
# and __init__ methods can only take Python objects, so the real
# constructor is here.
cdef _MemBuf MemBuf_init(const void *memory, size_t size):
    cdef _MemBuf ret = _MemBuf()
    ret.memory = memory # malloced void pointer
    ret.size = size # size of pointer in bytes
    return ret
