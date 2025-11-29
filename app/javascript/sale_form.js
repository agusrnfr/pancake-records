(function() {
  let saleFormInitialized = false;
  let productIndex = 1;
  let addProductListenerRegistered = false;
  
  function formatCurrency(amount) {
    const num = parseFloat(amount);
    return '$' + num.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }

  function initSaleForm() {
    const form = document.getElementById('sale-form');
    if (!form) return;

    // Evitar inicialización múltiple
    if (saleFormInitialized) return;
    saleFormInitialized = true;
    
    // Resetear productIndex contando las filas existentes
    const existingRows = document.querySelectorAll('.product-row');
    productIndex = existingRows.length;

    const productsData = {};
    
    // Cargar datos de productos desde data attribute
    const productsDataElement = document.getElementById('products-data');
    if (productsDataElement) {
      try {
        const data = JSON.parse(productsDataElement.textContent);
        Object.assign(productsData, data);
      } catch (e) {
        console.error('Error parsing products data:', e);
      }
    }

    // Calcular stock disponible para un producto (stock original - cantidad usada en otras filas)
    function getAvailableStock(productId, excludeRow = null) {
      if (!productsData[productId]) return 0;
      
      const originalStock = productsData[productId].stock;
      let usedStock = 0;
      
      document.querySelectorAll('.product-row').forEach(function(row) {
        if (row === excludeRow) return;
        
        const productSelect = row.querySelector('.product-select');
        const quantityInput = row.querySelector('.quantity-input');
        
        if (productSelect && productSelect.value && quantityInput && quantityInput.value) {
          const selectedProductId = parseInt(productSelect.value);
          if (selectedProductId === productId) {
            usedStock += parseInt(quantityInput.value) || 0;
          }
        }
      });
      
      return Math.max(0, originalStock - usedStock);
    }

    // Actualizar opciones disponibles en todos los selects
    function updateProductOptions() {
      document.querySelectorAll('.product-select').forEach(function(select) {
        const currentValue = select.value;
        const currentRow = select.closest('.product-row');
        
        // Guardar el valor actual
        const previousValue = currentValue;
        
        // Actualizar cada opción
        Array.from(select.options).forEach(function(option) {
          if (option.value === '') return; // No modificar la opción vacía
          
          const productId = parseInt(option.value);
          const availableStock = getAvailableStock(productId, currentRow);
          
          // Si es la opción seleccionada y no hay stock, deseleccionar
          if (option.value === previousValue && availableStock === 0) {
            select.value = '';
            const quantityInput = currentRow.querySelector('.quantity-input');
            if (quantityInput) {
              quantityInput.value = 1;
              quantityInput.setAttribute('max', 1);
            }
            updateRowCalculations(currentRow);
          }
          
          // Deshabilitar si no hay stock disponible
          option.disabled = availableStock === 0;
          
          // Actualizar el texto para mostrar stock disponible
          const productName = option.getAttribute('data-name');
          const productPrice = option.getAttribute('data-price');
          
          if (availableStock === 0) {
            option.textContent = productName + ' - Sin stock disponible';
          } else {
            // Mostrar stock disponible actualizado
            if (productName && productPrice) {
              option.textContent = productName + ' (Stock disponible: ' + availableStock + ') - $' + parseFloat(productPrice).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            }
          }
        });
      });
    }

    // Actualizar cálculos de una fila específica
    function updateRowCalculations(row) {
      const productSelect = row.querySelector('.product-select');
      const quantityInput = row.querySelector('.quantity-input');
      const unitPriceInput = row.querySelector('.unit-price');
      
      if (productSelect && productSelect.value && quantityInput && quantityInput.value) {
        const productId = parseInt(productSelect.value);
        const product = productsData[productId];
        const quantity = parseInt(quantityInput.value) || 0;
        
        if (product) {
          const unitPrice = product.price;
          
          if (unitPriceInput) unitPriceInput.value = formatCurrency(unitPrice);
        }
      } else {
        if (unitPriceInput) unitPriceInput.value = formatCurrency(0);
      }
    }

    // Función para actualizar total
    function updateCalculations() {
      let total = 0;
      
      document.querySelectorAll('.product-row').forEach(function(row) {
        updateRowCalculations(row);
        
        const productSelect = row.querySelector('.product-select');
        const quantityInput = row.querySelector('.quantity-input');
        
        if (productSelect && productSelect.value && quantityInput && quantityInput.value) {
          const productId = parseInt(productSelect.value);
          const product = productsData[productId];
          const quantity = parseInt(quantityInput.value) || 0;
          
          if (product) {
            const unitPrice = product.price;
            const rowTotal = unitPrice * quantity;
            total += rowTotal;
          }
        }
      });
      
      // Mostrar total
      const totalElement = document.getElementById('total-amount');
      if (totalElement) {
        totalElement.textContent = formatCurrency(total);
      }
    }

    // Actualizar stock máximo y validaciones de una fila
    function updateRowStockLimits(row) {
      const productSelect = row.querySelector('.product-select');
      const quantityInput = row.querySelector('.quantity-input');
      
      if (productSelect && productSelect.value) {
        const productId = parseInt(productSelect.value);
        const availableStock = getAvailableStock(productId, row);
        
        if (quantityInput) {
          // Establecer máximo según stock disponible
          quantityInput.setAttribute('max', availableStock);
          
          // Si la cantidad actual excede el stock disponible, ajustarla
          const currentQuantity = parseInt(quantityInput.value) || 0;
          if (currentQuantity > availableStock) {
            quantityInput.value = availableStock;
            if (availableStock === 0) {
              alert('No hay stock disponible para este producto');
            } else {
              alert(`Stock disponible: ${availableStock}. La cantidad se ajustó automáticamente.`);
            }
          }
          
          // Si el stock disponible es 0, deshabilitar el input
          quantityInput.disabled = availableStock === 0;
        }
      } else {
        if (quantityInput) {
          quantityInput.removeAttribute('max');
          quantityInput.disabled = false;
        }
      }
    }

    // Agregar nuevo producto - usar event listener directo en el botón
    const addProductBtn = document.getElementById('add-product-btn');
    if (addProductBtn && !addProductBtn.dataset.listenerAdded) {
      addProductBtn.dataset.listenerAdded = 'true';
      addProductBtn.addEventListener('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        
        const container = document.getElementById('products-container');
        if (!container) return;

        const firstRow = container.querySelector('.product-row');
        if (!firstRow) return;

        const newRow = firstRow.cloneNode(true);
        newRow.dataset.productIndex = productIndex;
        
        // Actualizar nombres de campos
        newRow.querySelectorAll('select, input').forEach(function(input) {
          if (input.name) {
            input.name = input.name.replace(/\[0\]/, `[${productIndex}]`);
          }
          if (input.dataset.index !== undefined) {
            input.dataset.index = productIndex;
          }
        });
        
        // Limpiar valores
        const productSelect = newRow.querySelector('.product-select');
        const quantityInput = newRow.querySelector('.quantity-input');
        const unitPriceInput = newRow.querySelector('.unit-price');
        
        if (productSelect) productSelect.value = '';
        if (quantityInput) {
          quantityInput.value = 1;
          quantityInput.removeAttribute('max');
          quantityInput.disabled = false;
        }
        if (unitPriceInput) unitPriceInput.value = formatCurrency(0);
        
        // Mostrar botón eliminar
        const removeBtn = newRow.querySelector('.btn-remove-product');
        if (removeBtn) {
          removeBtn.style.display = 'block';
          removeBtn.dataset.index = productIndex;
        }
        
        container.appendChild(newRow);
        
        // Actualizar opciones disponibles
        updateProductOptions();
        
        productIndex++;
      });
    }

    // Eliminar producto
    document.addEventListener('click', function(e) {
      if (e.target.closest('.btn-remove-product')) {
        const row = e.target.closest('.product-row');
        if (!row) return;

        const rows = document.querySelectorAll('.product-row');
        
        if (rows.length > 1) {
          row.remove();
          updateProductOptions();
          updateCalculations();
        } else {
          alert('Debe tener al menos un producto en la venta');
        }
      }
    });

    // Event listeners para cambios en producto
    document.addEventListener('change', function(e) {
      if (e.target.classList.contains('product-select')) {
        const row = e.target.closest('.product-row');
        if (!row) return;

        const productSelect = row.querySelector('.product-select');
        const quantityInput = row.querySelector('.quantity-input');
        
        if (productSelect && productSelect.value) {
          const productId = parseInt(productSelect.value);
          const availableStock = getAvailableStock(productId, row);
          
          if (quantityInput) {
            // Resetear cantidad a 1 si hay stock, o 0 si no hay
            quantityInput.value = availableStock > 0 ? 1 : 0;
            quantityInput.setAttribute('max', availableStock);
            quantityInput.disabled = availableStock === 0;
          }
        } else {
          if (quantityInput) {
            quantityInput.value = 1;
            quantityInput.removeAttribute('max');
            quantityInput.disabled = false;
          }
        }
        
        // Actualizar opciones en todos los selects
        updateProductOptions();
        updateCalculations();
      }
    });

    // Event listeners para cambios en cantidad
    document.addEventListener('input', function(e) {
      if (e.target.classList.contains('quantity-input')) {
        const row = e.target.closest('.product-row');
        if (!row) return;

        updateRowStockLimits(row);
        updateProductOptions();
        updateCalculations();
      }
    });

    // Event listener para cambios (también para validación)
    document.addEventListener('change', function(e) {
      if (e.target.classList.contains('quantity-input')) {
        const row = e.target.closest('.product-row');
        if (!row) return;

        updateRowStockLimits(row);
        updateProductOptions();
        updateCalculations();
      }
    });

    // Validación antes de enviar
    form.addEventListener('submit', function(e) {
      const productRows = document.querySelectorAll('.product-row');
      let hasProduct = false;
      let hasErrors = false;
      
      productRows.forEach(function(row) {
        const productSelect = row.querySelector('.product-select');
        const quantityInput = row.querySelector('.quantity-input');
        
        if (productSelect && productSelect.value) {
          hasProduct = true;
          
          const productId = parseInt(productSelect.value);
          const quantity = parseInt(quantityInput.value) || 0;
          const availableStock = getAvailableStock(productId, row);
          
          if (quantity > availableStock) {
            hasErrors = true;
            alert(`El producto "${productsData[productId].name}" no tiene suficiente stock disponible (disponible: ${availableStock})`);
          }
          
          if (quantity <= 0) {
            hasErrors = true;
            alert('La cantidad debe ser mayor a 0');
          }
        }
      });
      
      if (!hasProduct) {
        e.preventDefault();
        alert('Debe agregar al menos un producto a la venta');
        return false;
      }
      
      if (hasErrors) {
        e.preventDefault();
        return false;
      }
    });

    // Inicializar
    updateProductOptions();
    updateCalculations();
    
    // Actualizar límites de stock en la fila inicial
    document.querySelectorAll('.product-row').forEach(function(row) {
      updateRowStockLimits(row);
    });
  }

  // Inicializar cuando el DOM esté listo
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
      saleFormInitialized = false;
      initSaleForm();
    });
  } else {
    initSaleForm();
  }

  // También inicializar en eventos de Turbo
  document.addEventListener('turbo:load', function() {
    const addProductBtn = document.getElementById('add-product-btn');
    if (addProductBtn) {
      addProductBtn.removeAttribute('data-listener-added');
    }
    saleFormInitialized = false;
    initSaleForm();
  });
  
  document.addEventListener('turbo:render', function() {
    const addProductBtn = document.getElementById('add-product-btn');
    if (addProductBtn) {
      addProductBtn.removeAttribute('data-listener-added');
    }
    saleFormInitialized = false;
    initSaleForm();
  });
  
  // Resetear cuando se navega fuera
  document.addEventListener('turbo:before-cache', function() {
    saleFormInitialized = false;
  });
})();
