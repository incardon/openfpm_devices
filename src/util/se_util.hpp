/*
 * se_util.hpp
 *
 *  Created on: Oct 22, 2015
 *      Author: i-bird
 */

#ifndef OPENFPM_DATA_SRC_UTIL_SE_UTIL_HPP_
#define OPENFPM_DATA_SRC_UTIL_SE_UTIL_HPP_

// Macro that decide what to do in case of error
#ifdef STOP_ON_ERROR
#define ACTION_ON_ERROR(error) exit(1);
#define THROW noexcept(true)
#elif defined(THROW_ON_ERROR)
#define ACTION_ON_ERROR(error) if (!std::uncaught_exception()) throw error;
#define THROW noexcept(false)
#else
#define ACTION_ON_ERROR(error)
#define THROW noexcept(true)
#endif


#endif /* OPENFPM_DATA_SRC_UTIL_SE_UTIL_HPP_ */
