document.addEventListener("turbo:load", function() {
  new SaleFormHandler();
});

class SaleFormHandler {
  constructor() {
    this.form = document.getElementById('sale-form');
    this.container = document.getElementById('products-container');
    this.addProductBtn = document.getElementById('add-product-btn');
    this.totalElement = document.getElementById('total-amount');
    this.template = document.getElementById('sale-product-fields-template');
    
    // Cargamos los datos una sola vez
    this.productsData = this.loadProductsData();

    if (this.form && this.container) {
      this.init();
    }
  }

  init() {
    // Listeners globales para eventos delegados
    this.container.addEventListener('click', (e) => this.handleRemoveRow(e));
    
    // Al cambiar producto o cantidad, recalculamos stock y totales
    this.container.addEventListener('change', (e) => this.handleChange(e));
    this.container.addEventListener('input', (e) => this.handleInput(e));
    
    if (this.addProductBtn) {
      this.addProductBtn.addEventListener('click', (e) => {
        e.preventDefault();
        this.addNewRow();
      });
    }

    this.form.addEventListener('submit', (e) => this.handleSubmit(e));

    // Mostrar/ocultar botones de eliminar según cantidad de filas
    this.updateRemoveButtons();
    
    // Ejecutar lógica inicial
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
      console.error("Error cargando JSON", e);
      return {};
    }
  }

  // Calcula stock disponible para un producto excluyendo lo usado en una fila específica
  getAvailableStock(productId, excludeRow = null) {
    if (!productId || !this.productsData[productId]) return 0;

    const originalStock = this.productsData[productId].stock;
    let usedInOtherRows = 0;

    this.container.querySelectorAll('.product-row').forEach(row => {
      if (row === excludeRow) return;
      
      // Ignorar filas marcadas para destrucción
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

  // Actualiza los textos de las opciones de TODOS los selects
  updateProductOptions() {
    if (!this.productsData) return;

    this.container.querySelectorAll('.product-row').forEach(row => {
      // Ignorar filas marcadas para destrucción
      const destroyInput = row.querySelector('.destroy-input');
      if (destroyInput && destroyInput.value === 'true') return;

      const select = row.querySelector('.product-select');
      if (!select) return;

      const currentSelectedValue = select.value;

      Array.from(select.options).forEach(option => {
        if (!option.value) return; // Saltar placeholder

        const productId = option.value;
        const product = this.productsData[productId];
        if (!product) return;

        // Stock disponible para ESTA fila (ignorando su propio consumo)
        const availableStock = this.getAvailableStock(productId, row);

        const productName = option.getAttribute('data-name') || product.name;
        const productPrice = option.getAttribute('data-price') || product.price;
        const formattedPrice = parseFloat(productPrice).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",");

        if (availableStock === 0) {
          option.textContent = `${productName} - Sin stock disponible`;
          // Deshabilitar si no es el seleccionado actualmente
          if (option.value !== currentSelectedValue) {
            option.disabled = true;
          }
        } else {
          option.textContent = `${productName} (Stock disponible: ${availableStock}) - $${formattedPrice}`;
          option.disabled = false;
        }
      });
    });
  }

  addNewRow() {
    // Usar el template de Rails
    if (!this.template) {
      console.error('Template no encontrado');
      return;
    }

    // Obtener el HTML del template
    let newHtml = this.template.innerHTML;

    // Generar un índice único (Timestamp)
    const newIndex = new Date().getTime();

    // Reemplazar el marcador de posición de Rails (NEW_RECORD) por el índice real
    newHtml = newHtml.replace(/NEW_RECORD/g, newIndex);

    // Crear contenedor temporal para parsear el HTML
    const tempContainer = document.createElement('div');
    tempContainer.innerHTML = newHtml.trim();

    const newRow = tempContainer.querySelector('.product-row');
    if (!newRow) return;

    // Limpiar valores
    const productSelect = newRow.querySelector('.product-select');
    const quantityInput = newRow.querySelector('.quantity-input');
    const unitPriceInput = newRow.querySelector('.unit-price');
    const destroyInput = newRow.querySelector('.destroy-input');

    if (productSelect) productSelect.value = '';
    if (quantityInput) quantityInput.value = 1;
    if (unitPriceInput) unitPriceInput.value = '$0.00';
    if (destroyInput) destroyInput.value = 'false';

    // Mostrar botón eliminar en la nueva fila
    const removeBtn = newRow.querySelector('.btn-remove-product');
    if (removeBtn) removeBtn.style.display = 'block';

    this.container.appendChild(newRow);

    // Actualizar botones de eliminar y recalcular
    this.updateRemoveButtons();
    this.updateProductOptions();
    this.updateStockValidation();
  }

  handleRemoveRow(e) {
    if (e.target.closest('.btn-remove-product')) {
      const row = e.target.closest('.product-row');
      const visibleRows = this.container.querySelectorAll('.product-row:not([style*="display: none"])');
      
      if (visibleRows.length > 1) {
        // Si la fila tiene un ID (existe en BD), marcarla para destrucción
        const idInput = row.querySelector('input[name*="[id]"]');
        const destroyInput = row.querySelector('.destroy-input');
        
        if (idInput && idInput.value) {
          // Marcar para destrucción y ocultar
          if (destroyInput) destroyInput.value = 'true';
          row.style.display = 'none';
        } else {
          // Si es nueva (sin ID), simplemente remover del DOM
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

  updateRemoveButtons() {
    const visibleRows = this.container.querySelectorAll('.product-row:not([style*="display: none"])');
    
    visibleRows.forEach((row, index) => {
      const removeBtn = row.querySelector('.btn-remove-product');
      if (removeBtn) {
        // Mostrar el botón solo si hay más de una fila visible
        removeBtn.style.display = visibleRows.length > 1 ? 'block' : 'none';
      }
    });
  }

  handleChange(e) {
    const target = e.target;

    // Cuando cambia el SELECT
    if (target.classList.contains('product-select')) {
      const row = target.closest('.product-row');
      this.updateRowPrice(row);
      
      // Si seleccionó un producto y la cantidad está vacía o es 0, poner 1 por defecto
      const qtyInput = row.querySelector('.quantity-input');
      if (qtyInput && (!qtyInput.value || qtyInput.value == 0)) {
        const productId = target.value;
        if (productId) {
          const available = this.getAvailableStock(productId, row);
          if (available > 0) qtyInput.value = 1;
        }
      }
    }
    
    // Recalcular todo
    this.updateProductOptions();
    this.updateStockValidation();
    this.calculateTotal();
  }

  handleInput(e) {
    // Mientras escribe en QUANTITY
    if (e.target.classList.contains('quantity-input')) {
      this.updateProductOptions();
      this.updateStockValidation();
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

  // Validación y actualización de inputs de cantidad
  updateStockValidation() {
    this.container.querySelectorAll('.product-row').forEach(row => {
      // Ignorar filas marcadas para destrucción
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
      const currentQty = parseInt(qtyInput.value) || 0;
      
      // Stock disponible TOTAL para esta fila (stock original - lo que usan los demás)
      const availableForThisRow = this.getAvailableStock(productId, row);

      // Actualizar atributo max
      qtyInput.max = availableForThisRow;

      // Validación visual
      if (currentQty > availableForThisRow) {
        qtyInput.classList.add('is-invalid');
        qtyInput.title = `Stock insuficiente. Máximo disponible: ${availableForThisRow}`;
      } else {
        qtyInput.classList.remove('is-invalid');
        qtyInput.title = '';
      }
    });
  }

  calculateTotal() {
    let total = 0;
    this.container.querySelectorAll('.product-row').forEach(row => {
      // Ignorar filas marcadas para destrucción
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
    
    // Ejecutamos la validación una última vez
    this.updateStockValidation();
    
    // Verificar inputs inválidos (exceso de stock)
    const invalidInputs = this.container.querySelectorAll('.quantity-input.is-invalid');
    if (invalidInputs.length > 0) {
      isValid = false;
      alert("Por favor corrige las cantidades. Estás superando el stock disponible.");
      invalidInputs[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
      invalidInputs[0].focus();
      e.preventDefault();
      return;
    }

    // Verificar que haya al menos un producto seleccionado
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
