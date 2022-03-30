package com.vmware.acmecatalog.service;

import com.vmware.acmecatalog.Request.ProductRequest;
import com.vmware.acmecatalog.response.CreateProductResponse;
import com.vmware.acmecatalog.response.GetProductResponse;
import com.vmware.acmecatalog.response.GetProductsResponse;

public interface IAcmeCatalogService {

    GetProductsResponse getProducts();

    GetProductResponse getProduct(String id);

    CreateProductResponse createProduct(ProductRequest product);
}
