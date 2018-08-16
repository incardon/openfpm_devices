/*
 * CudaMemory.cu
 *
 *  Created on: Aug 17, 2014
 *      Author: Pietro Incardona
 */

/**
 * \brief This class create instructions to allocate, and destroy GPU memory
 * 
 * This class allocate, destroy, resize GPU buffer, 
 * eventually if direct, comunication is not supported, it can instruction
 * to create an Host Pinned memory.
 * 
 * Usage:
 * 
 * CudaMemory m = new CudaMemory();
 * 
 * m.allocate(1000*sizeof(int));
 * int * ptr = m.getPointer();
 * ptr[999] = 1000;
 * ....
 * 
 * 
 */

#ifndef CUDA_MEMORY_CUH_
#define CUDA_MEMORY_CUH_

#if __CUDACC_VER_MAJOR__ < 9
#define EXCEPT_MC
#else
#define EXCEPT_MC noexcept
#endif

#include "config.h"
#include "memory.hpp"
#include <iostream>
#ifdef SE_CLASS2
#include "Memleak_check.hpp"
#endif

class CudaMemory : public memory
{
	//! Is the host memory synchronized with the GPU memory
	bool is_hm_sync;
	
	//! Size of the memory
	size_t sz;
	
	//! device memory
	void * dm;
	
	//! host memory
	mutable void * hm;

	//! Reference counter
	size_t ref_cnt;
	
	//! Allocate an host buffer
	void allocate_host(size_t sz) const;
	
	//! copy from GPU to GPU buffer directly
	bool copyDeviceToDevice(const CudaMemory & m);
	
	//! copy from Pointer to GPU
	bool copyFromPointer(const void * ptr);
	
public:
	
	//! flush the memory
	virtual bool flush();
	//! allocate memory
	virtual bool allocate(size_t sz);
	//! destroy memory
	virtual void destroy();
	//! copy from a General device
	virtual bool copy(const memory & m);
	//! the the size of the allocated memory
	virtual size_t size() const;
	//! resize the momory allocated
	virtual bool resize(size_t sz);
	//! get a readable pointer with the data
	virtual void * getPointer();
	
	//! get a readable pointer with the data
	virtual const void * getPointer() const;
	
	//! get a readable pointer with the data
	virtual void * getDevicePointer();

	//! Move memory from device to host
	virtual void deviceToHost();

	//! Move memory from device to host, just one chunk
	virtual void deviceToHost(size_t start, size_t stop);

	//! get the device pointer, but do not copy the memory from host to device
	virtual void * getDevicePointerNoCopy();

	//! fill the buffer with a byte
	virtual void fill(unsigned char c);

	//! This function notify that the device memory is not sync with
	//! the host memory, is called when a task is performed that write
	//! on the buffer
	void isNotSync() {is_hm_sync = false;}
	
	public:
	
	//! Increment the reference counter
	virtual void incRef()
	{ref_cnt++;}

	//! Decrement the reference counter
	virtual void decRef()
	{ref_cnt--;}
	
	//! Return the reference counter
	virtual long int ref()
	{
		return ref_cnt;
	}

	/*! \brief Allocated Memory is never initialized
	 *
	 * \return false
	 *
	 */
	bool isInitialized()
	{
		return false;
	}
	
	// Copy the Heap memory
	CudaMemory & operator=(const CudaMemory & mem)
	{
		copy(mem);
		return *this;
	}

	// Copy the Cuda memory
	CudaMemory(const CudaMemory & mem)
	:CudaMemory()
	{
		allocate(mem.size());
		copy(mem);
	}

	CudaMemory(CudaMemory && mem) EXCEPT_MC
	{

		bool t_is_hm_sync = is_hm_sync;
		size_t t_sz = sz;
		void * t_dm = dm;
		void * t_hm = hm;
		long int t_ref_cnt = ref_cnt;

		is_hm_sync = mem.is_hm_sync;
		sz = mem.sz;
		dm = mem.dm;
		hm = mem.hm;

		// reset mem
		mem.is_hm_sync = t_is_hm_sync;
		mem.sz = t_sz;
		mem.dm = t_dm;
		mem.hm = t_hm;
		mem.ref_cnt = t_ref_cnt;
	}
	
	//! Constructor
	CudaMemory():is_hm_sync(true),sz(0),dm(0),hm(0),ref_cnt(0) {};
	
	//! Destructor
	~CudaMemory()	
	{
		if(ref_cnt == 0)
			destroy();
		else
			std::cerr << "Error: " << __FILE__ << " " << __LINE__ << " destroying a live object" << "\n"; 
	};
};

#endif

