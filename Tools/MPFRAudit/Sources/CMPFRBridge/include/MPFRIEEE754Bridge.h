#ifndef MPFR_IEEE754_BRIDGE_H
#define MPFR_IEEE754_BRIDGE_H

#ifdef __cplusplus
extern "C" {
#endif

const char *mpfr_ieee754_version(void);

double mpfr_ieee754_exp(double x);
double mpfr_ieee754_exp2(double x);
double mpfr_ieee754_exp10(double x);
double mpfr_ieee754_expm1(double x);
double mpfr_ieee754_log(double x);
double mpfr_ieee754_log2(double x);
double mpfr_ieee754_log10(double x);
double mpfr_ieee754_log1p(double x);

double mpfr_ieee754_sin(double x);
double mpfr_ieee754_cos(double x);
double mpfr_ieee754_tan(double x);
double mpfr_ieee754_asin(double x);
double mpfr_ieee754_acos(double x);
double mpfr_ieee754_atan(double x);
double mpfr_ieee754_sinpi(double x);
double mpfr_ieee754_cospi(double x);
double mpfr_ieee754_tanpi(double x);

double mpfr_ieee754_cbrt(double x);
double mpfr_ieee754_sinh(double x);
double mpfr_ieee754_cosh(double x);
double mpfr_ieee754_tanh(double x);
double mpfr_ieee754_asinh(double x);
double mpfr_ieee754_acosh(double x);
double mpfr_ieee754_atanh(double x);
double mpfr_ieee754_erf(double x);
double mpfr_ieee754_erfc(double x);
double mpfr_ieee754_tgamma(double x);
double mpfr_ieee754_lgamma(double x);

double mpfr_ieee754_pow(double x, double y);
double mpfr_ieee754_atan2(double y, double x);
double mpfr_ieee754_hypot(double x, double y);

void mpfr_ieee754_sincos(double x, double *out_sin, double *out_cos);
void mpfr_ieee754_sincospi(double x, double *out_sin, double *out_cos);

#ifdef __cplusplus
}
#endif

#endif
