#include <bits/stdc++.h>

template<typename T>
class DSU {
public:
    size_t _n;
    std::vector<T> _a;
    std::vector<T> _pa;

    DSU() {}
    DSU(const T n) {
        init(n);
    }

    DSU(const std::vector<T>& a) {
        const size_t n = _a.size();
        init(n);
        for (T x : a) {
            this->_a.push_back(x);
        }
    }

    void init(const size_t n) {
        this->_n = n;
        this->_a.resize(n);  
        this->_pa.resize(n);
        for (size_t i = 0; i < n; i++) {
            this->_pa[i] = i;
        }
    }
};
