(function() {
  let handlerInstance = null;

  function initSaleForm() {
    const form = document.getElementById('sale-form');
    if (!form) return;

    if (handlerInstance) return;

    try {
      handlerInstance = new SaleFormHandler();
    } catch (error) {
      console.error('SaleForm: Error al inicializar', error);
    }
  }

  function resetHandler() {
    handlerInstance = null;
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
      setTimeout(initSaleForm, 100);
    });
  } else {
    setTimeout(initSaleForm, 100);
  }

  document.addEventListener('turbo:load', function() {
    resetHandler();
    setTimeout(initSaleForm, 100);
  });

  document.addEventListener('turbo:render', function() {
    resetHandler();
    setTimeout(initSaleForm, 100);
  });

  window.addEventListener('load', function() {
    if (!handlerInstance) {
      setTimeout(initSaleForm, 100);
    }
  });
})();

class SaleFormHandler {
  constructor() {
    this.form = document.getElementById('sale-form');
    this.container = document.getElementById('products-container');
    this.addProductBtn = document.getElementById('add-product-btn');
    this.totalElement = document.getElementById('total-amount');
    this.template = document.getElementById('sale-product-fields-template');
    this.productsData = this.loadProductsData();

    if (this.form && this.container) {
      this.init();
    }
  }

  init() {
    if (!this.form || !this.container) return;

    this.container.addEventListener('click', (e) => this.handleRemoveRow(e));
    this.container.addEventListener('change', (e) => this.handleChange(e));
    this.container.addEventListener('input', (e) => this.handleInput(e));
    
    if (this.addProductBtn) {
      this.addProductBtn.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        this.addNewRow();
      });
    }

    this.form.addEventListener('submit', (e) => this.handleSubmit(e));

    this.updateRemoveButtons();
    this.updateProductOptions();
    this.updateStockValidation();
    this.calculateTotal();
  }

  loadProductsData() {
    const el = document.getElementById('products-data');
    if (!el) return {};
    try {
      return JSON.parse(el.textContent);
    } catch (e) {
      return {};
    }
  }

  getAvailableStock(productId, excludeRow = null) {
    if (!productId || !this.productsData[productId]) return 0;

    const originalStock = this.productsData[productId].stock;
    let usedInOtherRows = 0;

    this.container.querySelectorAll('.product-row').forEach(row => {
      if (row === excludeRow) return;
      
      const destroyInput = row.querySelector('.destroy-input');
      if (destroyInput && destroyInput.value === 'true') return;

      const select = row.querySelector('.product-select');
      const qtyInput = row.querySelector('.quantity-input');

      if (select && select.value == productId) {
        usedInOtherRows += (parseInt(qtyInput.value) || 0);
      }
    });

    return Math.max(0, originalStock - usedInOtherRows);
  }

  updateProductOptions() {
    if (!this.productsData) return;

    this.container.querySelectorAll('.product-row').forEach(row => {
      const destroyInput = row.querySelector('.destroy-input');
      if (destroyInput && destroyInput.value === 'true') return;

      const select = row.querySelector('.product-select');
      if (!select) return;

      const currentSelectedValue = select.value;

      Array.from(select.options).forEach(option => {
        if (!option.value) return;

        const productId = option.value;
        const product = this.productsData[productId];
        if (!product) return;

        if (option.value === currentSelectedValue) {
          return;
        }

        const availableStock = this.getAvailableStock(productId, row);

        const productName = option.getAttribute('data-name') || product.name;
        const productPrice = option.getAttribute('data-price') || product.price;
        const formattedPrice = parseFloat(productPrice).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",");

        if (availableStock === 0) {
          option.textContent = `${productName} - Sin stock disponible`;
          option.disabled = true;
        } else {
          option.textContent = `${productName} (Stock disponible: ${availableStock}) - $${formattedPrice}`;
          option.disabled = false;
        }
      });
    });
  }

  addNewRow() {
    if (!this.template) return;

    let newHtml = this.template.innerHTML;
    const newIndex = new Date().getTime();
    newHtml = newHtml.replace(/NEW_RECORD/g, newIndex);

    const tempContainer = document.createElement('div');
    tempContainer.innerHTML = newHtml.trim();

    const newRow = tempContainer.querySelector('.product-row');
    if (!newRow) return;

    const productSelect = newRow.querySelector('.product-select');
    const quantityInput = newRow.querySelector('.quantity-input');
    const unitPriceInput = newRow.querySelector('.unit-price');
    const destroyInput = newRow.querySelector('.destroy-input');

    if (productSelect) productSelect.value = '';
    if (quantityInput) quantityInput.value = 1;
    if (unitPriceInput) unitPriceInput.value = '$0.00';
    if (destroyInput) destroyInput.value = 'false';

    const removeBtn = newRow.querySelector('.btn-remove-product');
    if (removeBtn) removeBtn.style.display = 'block';

    this.container.appendChild(newRow);

    this.updateRemoveButtons();
    this.updateProductOptions();
    this.updateStockValidation();
  }

  handleRemoveRow(e) {
    if (e.target.closest('.btn-remove-product')) {
      const row = e.target.closest('.product-row');
      const visibleRows = this.getVisibleRows();
      
      if (visibleRows.length > 1) {
        const idInput = row.querySelector('input[name*="[id]"]');
        const destroyInput = row.querySelector('.destroy-input');
        
        if (idInput && idInput.value) {
          if (destroyInput) destroyInput.value = 'true';
          row.classList.add('hidden-row');
          row.style.display = 'none';
        } else {
          row.remove();
        }
        
        this.updateRemoveButtons();
        this.updateProductOptions();
        this.updateStockValidation();
        this.calculateTotal();
      } else {
        alert("Debe haber al menos un producto.");
      }
    }
  }

  getVisibleRows() {
    const allRows = this.container.querySelectorAll('.product-row');
    return Array.from(allRows).filter(row => {
      if (row.classList.contains('hidden-row')) return false;
      const destroyInput = row.querySelector('.destroy-input');
      if (destroyInput && destroyInput.value === 'true') return false;
      return true;
    });
  }

  updateRemoveButtons() {
    const visibleRows = this.getVisibleRows();
    
    visibleRows.forEach((row, index) => {
      const removeBtn = row.querySelector('.btn-remove-product');
      if (removeBtn) {
        removeBtn.style.display = visibleRows.length > 1 ? 'block' : 'none';
      }
    });
  }

  handleChange(e) {
    const target = e.target;

    if (target.classList.contains('product-select')) {
      const row = target.closest('.product-row');
      this.updateRowPrice(row);
      
      const qtyInput = row.querySelector('.quantity-input');
      const productId = target.value;
      
      if (productId && qtyInput) {
        const available = this.getAvailableStock(productId, row);
        
        if (!qtyInput.value || qtyInput.value == 0) {
          if (available > 0) {
            qtyInput.value = 1;
          }
        } else {
          const currentQty = parseInt(qtyInput.value) || 0;
          if (currentQty > available && available > 0) {
            qtyInput.value = available;
            alert(`La cantidad ingresada (${currentQty}) excede el stock disponible. Se ajustó automáticamente a ${available}.`);
          } else if (currentQty > available && available === 0) {
            qtyInput.value = 0;
            alert(`La cantidad ingresada (${currentQty}) excede el stock disponible. No hay stock disponible para este producto.`);
          }
        }
      }
    }
    
    this.updateProductOptions();
    const editedRow = target.closest('.product-row');
    this.updateStockValidation(editedRow);
    this.calculateTotal();
  }

  handleInput(e) {
    if (e.target.classList.contains('quantity-input')) {
      this.updateProductOptions();
      const editedRow = e.target.closest('.product-row');
      this.updateStockValidation(editedRow);
      this.calculateTotal();
    }
  }

  updateRowPrice(row) {
    const select = row.querySelector('.product-select');
    const priceInput = row.querySelector('.unit-price');
    const product = this.productsData[select.value];

    if (product && priceInput) {
      priceInput.value = `$${parseFloat(product.price).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")}`;
    } else if (priceInput) {
      priceInput.value = '$0.00';
    }
  }

  updateStockValidation(editedRow = null) {
    this.container.querySelectorAll('.product-row').forEach(row => {
      const destroyInput = row.querySelector('.destroy-input');
      if (destroyInput && destroyInput.value === 'true') return;

      const select = row.querySelector('.product-select');
      const qtyInput = row.querySelector('.quantity-input');

      if (!select || !select.value) {
        if (qtyInput) {
          qtyInput.max = '';
          qtyInput.classList.remove('is-invalid');
        }
        return;
      }

      const productId = select.value;
      const product = this.productsData[productId];
      if (!product) return;

      const currentQty = parseInt(qtyInput.value) || 0;
      const availableForThisRow = this.getAvailableStock(productId, row);

      qtyInput.max = availableForThisRow;

      const isBeingEdited = editedRow && row === editedRow;
      
      if (isBeingEdited) {
        if (currentQty > availableForThisRow && availableForThisRow > 0) {
          const previousQty = currentQty;
          qtyInput.value = availableForThisRow;
          qtyInput.classList.remove('is-invalid');
          qtyInput.title = '';
          alert(`La cantidad ingresada (${previousQty}) excede el stock disponible. Se ajustó automáticamente a ${availableForThisRow}.`);
        } else if (currentQty > availableForThisRow && availableForThisRow === 0) {
          const previousQty = currentQty;
          qtyInput.value = 0;
          qtyInput.classList.add('is-invalid');
          qtyInput.title = 'No hay stock disponible';
          alert(`La cantidad ingresada (${previousQty}) excede el stock disponible. No hay stock disponible para este producto.`);
        } else {
          qtyInput.classList.remove('is-invalid');
          qtyInput.title = '';
        }
      } else {
        if (currentQty > availableForThisRow) {
          qtyInput.classList.add('is-invalid');
          qtyInput.title = `Stock insuficiente. Máximo disponible: ${availableForThisRow}`;
        } else {
          qtyInput.classList.remove('is-invalid');
          qtyInput.title = '';
        }
      }
    });
  }

  calculateTotal() {
    let total = 0;
    this.container.querySelectorAll('.product-row').forEach(row => {
      const destroyInput = row.querySelector('.destroy-input');
      if (destroyInput && destroyInput.value === 'true') return;

      const select = row.querySelector('.product-select');
      const qtyInput = row.querySelector('.quantity-input');
      
      if (select && select.value && qtyInput) {
        const product = this.productsData[select.value];
        const qty = parseInt(qtyInput.value) || 0;
        if (product) total += (product.price * qty);
      }
    });

    if (this.totalElement) {
      this.totalElement.textContent = `$${total.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")}`;
    }
  }

  handleSubmit(e) {
    let isValid = true;
    
    this.updateStockValidation();
    
    const invalidInputs = this.container.querySelectorAll('.quantity-input.is-invalid');
    if (invalidInputs.length > 0) {
      isValid = false;
      alert("Por favor corrige las cantidades. Estás superando el stock disponible.");
      invalidInputs[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
      invalidInputs[0].focus();
      e.preventDefault();
      return;
    }

    let hasProduct = false;
    let hasZero = false;
    
    this.container.querySelectorAll('.product-row').forEach(row => {
      const destroyInput = row.querySelector('.destroy-input');
      if (destroyInput && destroyInput.value === 'true') return;
      
      const qty = row.querySelector('.quantity-input').value;
      const select = row.querySelector('.product-select').value;
      
      if (select) {
        hasProduct = true;
        if (qty <= 0 || qty === '') {
          hasZero = true;
        }
      }
    });

    if (!hasProduct) {
      isValid = false;
      alert("Debe agregar al menos un producto a la venta");
    } else if (hasZero) {
      isValid = false;
      alert("Las cantidades deben ser mayores a 0");
    }

    if (!isValid) {
      e.preventDefault();
      e.stopPropagation();
    }
  }
}
