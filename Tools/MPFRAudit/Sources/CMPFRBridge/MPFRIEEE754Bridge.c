#include "MPFRIEEE754Bridge.h"
#include <math.h>
#include <mpfr.h>

static _Thread_local int tls_ready = 0;
static _Thread_local mpfr_t tls_x;
static _Thread_local mpfr_t tls_y;
static _Thread_local mpfr_t tls_r;

static inline void ensure_ieee754_tls(void) {
    if (!tls_ready) {
        mpfr_set_emin(-1073);
        mpfr_set_emax(1024);
        mpfr_init2(tls_x, 53);
        mpfr_init2(tls_y, 53);
        mpfr_init2(tls_r, 53);
        tls_ready = 1;
    }
}

static inline double finish_ieee754(int ternary) {
    mpfr_subnormalize(tls_r, ternary, MPFR_RNDN);
    return mpfr_get_d(tls_r, MPFR_RNDN);
}

#define DEFINE_MPFR_UNARY(NAME, MPFR_FN)                  \
    double mpfr_ieee754_##NAME(double x) {                \
        ensure_ieee754_tls();                             \
        mpfr_set_d(tls_x, x, MPFR_RNDN);                  \
        int t = MPFR_FN(tls_r, tls_x, MPFR_RNDN);         \
        return finish_ieee754(t);                         \
    }

const char *mpfr_ieee754_version(void) {
    return mpfr_get_version();
}

DEFINE_MPFR_UNARY(exp, mpfr_exp)
DEFINE_MPFR_UNARY(exp2, mpfr_exp2)
DEFINE_MPFR_UNARY(exp10, mpfr_exp10)
DEFINE_MPFR_UNARY(expm1, mpfr_expm1)
DEFINE_MPFR_UNARY(log, mpfr_log)
DEFINE_MPFR_UNARY(log2, mpfr_log2)
DEFINE_MPFR_UNARY(log10, mpfr_log10)
DEFINE_MPFR_UNARY(log1p, mpfr_log1p)

DEFINE_MPFR_UNARY(sin, mpfr_sin)
DEFINE_MPFR_UNARY(cos, mpfr_cos)
DEFINE_MPFR_UNARY(tan, mpfr_tan)
DEFINE_MPFR_UNARY(asin, mpfr_asin)
DEFINE_MPFR_UNARY(acos, mpfr_acos)
DEFINE_MPFR_UNARY(atan, mpfr_atan)

DEFINE_MPFR_UNARY(cbrt, mpfr_cbrt)
DEFINE_MPFR_UNARY(sinh, mpfr_sinh)
DEFINE_MPFR_UNARY(cosh, mpfr_cosh)
DEFINE_MPFR_UNARY(tanh, mpfr_tanh)
DEFINE_MPFR_UNARY(asinh, mpfr_asinh)
DEFINE_MPFR_UNARY(acosh, mpfr_acosh)
DEFINE_MPFR_UNARY(atanh, mpfr_atanh)
DEFINE_MPFR_UNARY(erf, mpfr_erf)
DEFINE_MPFR_UNARY(erfc, mpfr_erfc)
DEFINE_MPFR_UNARY(tgamma, mpfr_gamma)

double mpfr_ieee754_lgamma(double x) {
    ensure_ieee754_tls();
    mpfr_set_d(tls_x, x, MPFR_RNDN);
    int signp = 0;
    int t = mpfr_lgamma(tls_r, &signp, tls_x, MPFR_RNDN);
    return finish_ieee754(t);
}

#if MPFR_VERSION >= MPFR_VERSION_NUM(4, 2, 0)
DEFINE_MPFR_UNARY(sinpi, mpfr_sinpi)
DEFINE_MPFR_UNARY(cospi, mpfr_cospi)
DEFINE_MPFR_UNARY(tanpi, mpfr_tanpi)
#else
static double eval_pi_trig_fallback(double x, int kind) {
    ensure_ieee754_tls();
    if (!isfinite(x)) return NAN;
    double rem = remainder(x, 2.0);
    if (rem == 0.0) {
        if (kind == 1) return 1.0;
        return copysign(0.0, x);
    }
    if (fabs(rem) == 1.0) {
        if (kind == 1) return -1.0;
        if (kind == 0) return copysign(0.0, x);
        return copysign(0.0, -x);
    }
    if (fabs(rem) == 0.5) {
        if (kind == 0) return rem > 0.0 ? 1.0 : -1.0;
        if (kind == 1) return 0.0;
        return rem > 0.0 ? INFINITY : -INFINITY;
    }
    mpfr_exp_t saved_emin = mpfr_get_emin();
    mpfr_exp_t saved_emax = mpfr_get_emax();
    mpfr_set_emin(mpfr_get_emin_min());
    mpfr_set_emax(mpfr_get_emax_max());
    mpfr_t hi_x, hi_pi, hi_arg, hi_out;
    mpfr_inits2(256, hi_x, hi_pi, hi_arg, hi_out, (mpfr_ptr)0);
    mpfr_set_d(hi_x, rem, MPFR_RNDN);
    mpfr_const_pi(hi_pi, MPFR_RNDN);
    mpfr_mul(hi_arg, hi_x, hi_pi, MPFR_RNDN);
    if (kind == 0) {
        mpfr_sin(hi_out, hi_arg, MPFR_RNDN);
    } else if (kind == 1) {
        mpfr_cos(hi_out, hi_arg, MPFR_RNDN);
    } else {
        mpfr_tan(hi_out, hi_arg, MPFR_RNDN);
    }
    mpfr_set_emin(saved_emin);
    mpfr_set_emax(saved_emax);
    int t = mpfr_set(tls_r, hi_out, MPFR_RNDN);
    double out = finish_ieee754(t);
    mpfr_clears(hi_x, hi_pi, hi_arg, hi_out, (mpfr_ptr)0);
    return out;
}

double mpfr_ieee754_sinpi(double x) { return eval_pi_trig_fallback(x, 0); }
double mpfr_ieee754_cospi(double x) { return eval_pi_trig_fallback(x, 1); }
double mpfr_ieee754_tanpi(double x) { return eval_pi_trig_fallback(x, 2); }
#endif

double mpfr_ieee754_pow(double x, double y) {
    ensure_ieee754_tls();
    mpfr_set_d(tls_x, x, MPFR_RNDN);
    mpfr_set_d(tls_y, y, MPFR_RNDN);
    int t = mpfr_pow(tls_r, tls_x, tls_y, MPFR_RNDN);
    return finish_ieee754(t);
}

double mpfr_ieee754_atan2(double y, double x) {
    ensure_ieee754_tls();
    mpfr_set_d(tls_y, y, MPFR_RNDN);
    mpfr_set_d(tls_x, x, MPFR_RNDN);
    int t = mpfr_atan2(tls_r, tls_y, tls_x, MPFR_RNDN);
    return finish_ieee754(t);
}

double mpfr_ieee754_hypot(double x, double y) {
    ensure_ieee754_tls();
    mpfr_set_d(tls_x, x, MPFR_RNDN);
    mpfr_set_d(tls_y, y, MPFR_RNDN);
    int t = mpfr_hypot(tls_r, tls_x, tls_y, MPFR_RNDN);
    return finish_ieee754(t);
}

void mpfr_ieee754_sincos(double x, double *out_sin, double *out_cos) {
    *out_sin = mpfr_ieee754_sin(x);
    *out_cos = mpfr_ieee754_cos(x);
}

void mpfr_ieee754_sincospi(double x, double *out_sin, double *out_cos) {
    *out_sin = mpfr_ieee754_sinpi(x);
    *out_cos = mpfr_ieee754_cospi(x);
}
