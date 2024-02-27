/* eslint-disable no-async-promise-executor */
/* eslint-disable no-await-in-loop */
/* eslint-disable consistent-return */
/* eslint-disable no-confusing-arrow */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable dot-notation */
/* eslint-disable no-prototype-builtins */
import { track } from "lwc";
import b2bQuoteSummary from "vlocity_cmt/b2bQuoteSummary";
import { getCacheData } from "vlocity_cmt/b2bNavigationUtil";
import { formatCurrencyESM } from "c/cb2bUtils";
import { cloneDeep } from "vlocity_cmt/lodash";

export default class cb2bQuoteSummary extends b2bQuoteSummary {
  @track _feasibilityInfoResponse;

  _RECURRING_TOTAL_FIELD = "vlocity_cmt__RecurringTotal__c";
  _ONETIME_TOTAL_FIELD = "vlocity_cmt__OneTimeTotal__c";

  _TAX_ATTRIBUTE_FIELD = "ATT_TAX_PERC";
  _HSN_CODE_ATTRIBUTE_FIELD = "ATT_HSN_CODE";
  _SAC_CODE_ATTRIBUTE_FIELD = "ATT_SAC_CODE";

  _SUCESS_STATUS = "SUCCESS";
  _FAILURE_STATUS = "FAILURE";

  _ATTRIBUTES_SOURCE_FIELD = "vlocity_cmt__AttributeSelectedValues__c";
  _ATTRIBUTES_SOURCE_FIELD_1 = "attributeCategories";

  _ARTL_CUSTOM_FIELD = 'ARTL_Fetch_Item_Code_Response__c';

  /**
   * Existing method. Override to introduce the new node [feasibilityInfo]
   * @param {*} viewResponse
   */
  processGetCartItemsByView(viewResponse) {
    this._feasibilityInfoResponse = viewResponse?.IPResult?.feasibilityInfo;
    super.processGetCartItemsByView(viewResponse);
  }

  /**
   * Existing method. Override to introduce new columns for Media and Bandwith. Additionally, introduce custom currency formatter in the end.
   * @param {*} response
   */
  flattenResponse(response) {
    if (
      response?.records &&
      response?.records?.length > 0 &&
      this.isObject(this._feasibilityInfoResponse)
    ) {
      response.records.map((rec) => {
        // Media and Bandwith
        for (const [key, value] of Object.entries(
          this._feasibilityInfoResponse
        )) {
          const assetRefKey = this.isObject(
            rec.vlocity_cmt__AssetReferenceId__c
          )
            ? rec?.vlocity_cmt__AssetReferenceId__c?.value
            : rec.vlocity_cmt__AssetReferenceId__c;
          if (key === assetRefKey) {
            try {
              rec.ARTL_Media_Options__c = JSON.stringify(value.availableMedia);
              rec.ARTL_Media_SourceOptions__c = JSON.stringify(
                value.mediaBandwidth
              );
              // set default media
              rec.ARTL_Media_Options_SelectedValue__c = {
                value: value.default === null ? "" : value.default
              };
              rec.ARTL_Media_Rec_Id__c = { value: value.Id };
              rec.ARTL_Bandwith_Options__c = { value: "" };
              // rec.editRowMode = true;
              // set default bandwith

              if (value?.mediaBandwidth?.length > 0 && value.default !== null) {
                let bandwithOptions = value?.mediaBandwidth;

                if (bandwithOptions?.length > 0) {
                  let selectedBandwith = bandwithOptions.filter((obj) =>
                    obj.hasOwnProperty(value.default)
                  );
                  rec.ARTL_Bandwith_Options__c.value =
                    selectedBandwith[0][value.default];
                }
              }
            } catch (e) {
              console.log(
                "Failed at parsing the feasibility response",
                e?.messages
              );
            }
          }
        }
        // Attribute Based Column - ATT_TAX_PERC + Formula (ISNOTBLANK (QLI:@ATT_HSN_CODE) ||  ISNOTBLANK (QLI:@ATT_SAC_CODE))
        if (rec[this._ATTRIBUTES_SOURCE_FIELD]) {
          let parsedResponse = {};
          try {
            if (typeof rec[this._ATTRIBUTES_SOURCE_FIELD] === "string") {
              parsedResponse = JSON.parse(rec[this._ATTRIBUTES_SOURCE_FIELD]);
            } else {
              /*parsedResponse = JSON.parse(
                rec[this._ATTRIBUTES_SOURCE_FIELD].value
              );*/
              delete rec[this._ATTRIBUTES_SOURCE_FIELD];
            }
          } catch (e) {
            console.log(
              `Failed at reading the attribute selected values ${e?.message}`
            );
          }

          if (parsedResponse !== null && parsedResponse !== undefined) {
            rec.ATT_TAX_PERC = parsedResponse[this._TAX_ATTRIBUTE_FIELD];
            if (
              (parsedResponse[this._HSN_CODE_ATTRIBUTE_FIELD] !== null &&
                parsedResponse[this._HSN_CODE_ATTRIBUTE_FIELD] !== undefined) ||
              (parsedResponse[this._SAC_CODE_ATTRIBUTE_FIELD] !== null &&
                parsedResponse[this._SAC_CODE_ATTRIBUTE_FIELD] !== undefined)
            ) {
              rec.ATT_FORMULA = this._SUCESS_STATUS;
            } else {
              rec.ATT_FORMULA = this._FAILURE_STATUS;
            }
          }
        }

        // check one more field for attributes due to different API call
        if (rec[this._ATTRIBUTES_SOURCE_FIELD_1]) {
          // rec.ATT_TAX_PERC = parsedResponse[this._TAX_ATTRIBUTE_FIELD];

          if (rec[this._ATTRIBUTES_SOURCE_FIELD_1]) {
            if (rec[this._ATTRIBUTES_SOURCE_FIELD_1]?.records) {
              rec[this._ATTRIBUTES_SOURCE_FIELD_1]?.records.forEach((item) => {
                if (item?.productAttributes?.records?.length > 0) {
                  item.productAttributes.records.forEach((attribute) => {
                    if (attribute.code === this._TAX_ATTRIBUTE_FIELD) {
                      rec.ATT_TAX_PERC = attribute.userValues;
                    }
                  });
                }
              });
            }

            // formula based
            if (rec[this._ATTRIBUTES_SOURCE_FIELD_1]?.records) {
              rec[this._ATTRIBUTES_SOURCE_FIELD_1]?.records.forEach((item) => {
                if (item?.productAttributes?.records) {
                  let HNSAttribute = item.productAttributes.records.filter(
                    (r) => r["code"] === this._HSN_CODE_ATTRIBUTE_FIELD
                  );
                  let SACAttribute = item.productAttributes.records.filter(
                    (r) => r["code"] === this._SAC_CODE_ATTRIBUTE_FIELD
                  );
                  if (HNSAttribute[0] || SACAttribute[0]) {
                    if (
                      (HNSAttribute[0]?.userValues !== null &&
                        HNSAttribute[0]?.userValues !== undefined) ||
                      (SACAttribute[0]?.userValues !== null &&
                        SACAttribute[0]?.userValues !== undefined)
                    ) {
                      rec.ATT_FORMULA = this._SUCESS_STATUS;
                    } else {
                      rec.ATT_FORMULA = this._FAILURE_STATUS;
                    }
                  } else {
                    rec.ATT_FORMULA = this._FAILURE_STATUS;
                  }
                } else {
                  rec.ATT_FORMULA = this._FAILURE_STATUS;
                }
              });
            }
          } else {
            rec.ATT_FORMULA = this._FAILURE_STATUS;
          }
        }

        // if this field does not exist, remove the status field completely
        if(!rec[this._ARTL_CUSTOM_FIELD]) {
          rec.ATT_FORMULA = '';
        } else if(rec[this._ARTL_CUSTOM_FIELD]) {
          if(rec[this._ARTL_CUSTOM_FIELD]?.value === null) {
            rec.ATT_FORMULA = '';
          }
        }

        return { ...rec };
      });
    }

    let indexToInsertMediaColumnAfter = 2;
    let indexToInsertBandwithColumnAfter = 3;
    let indexToInsertBandwithColumnAfter1 = 4;
    let indexToInsertBandwithColumnAfter2 = 5;
    let indexToInsertBandwithColumnAfter3 = 6;

    let indexToInserAfterBandwithColumn = 7;
    let indexToInserAfterAttributeColumn = 8;

    let taxAttributeColumn = {
      apiName: "ATT_TAX_PERC",
      colGroups: ["All"],
      type: "text",
      label: "Tax",
      isVisible: true,
      isEditable: false,
      sortable: false,
      isSortable: false,
      sortBy: "",
      align: "center"
    };

    let attributeFormulaColumn = {
      apiName: "ATT_FORMULA",
      colGroups: ["All"],
      type: "text",
      label: "ERP Status",
      isVisible: true,
      isEditable: false,
      sortable: false,
      isSortable: false,
      sortBy: "",
      align: "center"
    };

    let newMediaColumn = {
      apiName: "ARTL_Media_Options_SelectedValue__c.value",
      colGroups: ["All"],
      type: "picklist",
      label: "Media",
      isVisible: true,
      isEditable: true,
      sortable: false,
      isSortable: false,
      sortBy: "",
      align: "center",
      isCustomPicklistField: true,
      picklistRowField: "ARTL_Media_Options__c"
    };

    let newMediaColumnOptions = {
      apiName: "ARTL_Media_Options__c",
      colGroups: ["All"],
      isSortable: false,
      type: "custom",
      sortable: false,
      sortBy: "",
      label: "Media Options",
      isVisible: false,
      isEditable: false,
      editMode: true,
      align: "center"
    };

    let newMediaSourceColumnOptions = {
      apiName: "ARTL_Media_SourceOptions__c",
      colGroups: ["All"],
      isSortable: false,
      sortable: false,
      sortBy: "",
      type: "custom",
      label: "Media Source Options",
      isVisible: false,
      isEditable: false,
      align: "center"
    };

    let newBandwithColumn = {
      apiName: "ARTL_Bandwith_Options__c.value",
      colGroups: ["All"],
      isSortable: false,
      sortable: false,
      type: "text",
      sortBy: "",
      label: "Max Bandwidth",
      isVisible: true,
      isEditable: false,
      align: "center"
    };

    let mediaIdColumn = {
      apiName: "ARTL_Media_Rec_Id__c.value",
      colGroups: ["All"],
      isSortable: false,
      sortable: false,
      sortBy: "",
      type: "text",
      label: "Media ID",
      isVisible: false,
      isEditable: false,
      align: "center"
    };

    // Function to check if array contains an object with a specific key-value pair
    function containsColumn(array, key, value) {
      return array.some((obj) => obj[key] === value);
    }

    if (
      !containsColumn(
        this.columnMap,
        "apiName",
        "ARTL_Media_Options_SelectedValue__c.value"
      )
    ) {
      this.columnMap.splice(
        indexToInsertMediaColumnAfter + 1,
        0,
        newMediaColumn
      );
      this.columnMap.splice(
        indexToInsertBandwithColumnAfter + 1,
        0,
        newBandwithColumn
      );
      this.columnMap.splice(
        indexToInsertBandwithColumnAfter1 + 1,
        0,
        newMediaColumnOptions
      );
      this.columnMap.splice(
        indexToInsertBandwithColumnAfter2 + 1,
        0,
        newMediaSourceColumnOptions
      );
      this.columnMap.splice(
        indexToInsertBandwithColumnAfter3 + 1,
        0,
        mediaIdColumn
      );
      // attribute + formula
      this.columnMap.splice(
        indexToInserAfterBandwithColumn + 1,
        0,
        taxAttributeColumn
      );

      this.columnMap.splice(
        indexToInserAfterAttributeColumn + 1,
        0,
        attributeFormulaColumn
      );
    }
    super.flattenResponse(response);
    this.showTable = false;
    setTimeout(() => {
      this.applyCustomCurrencyFormatting();
    }, 50);
  }

  /**
   * Custom currency formatting. Post-process the rows and read the price fields from the source response.
   */
  async applyCustomCurrencyFormatting() {
    let sourceData = getCacheData(this.QuoteSummaryResponseKey);
    if (sourceData?.records?.length > 0) {
      this.showTable = false;
      let newTable = [];
      newTable = cloneDeep(this.tableData);

      if (newTable?.length > 0) {
        try {
          for (const row of newTable) {
            let foundSourceRow = sourceData.records.filter((sourceRow) =>
              typeof sourceRow?.Id === "object"
                ? sourceRow?.Id.value === row.Id[0].val
                : sourceRow?.Id === row.Id[0].val
            );
            if (
              row[this._RECURRING_TOTAL_FIELD] &&
              foundSourceRow?.length > 0
            ) {
              if (row[this._RECURRING_TOTAL_FIELD].length > 1) {
                for (let price of row[this._RECURRING_TOTAL_FIELD]) {
                  const rootItemId = price?.orgProdId;
                  if (price?.orgProdId === foundSourceRow[0]?.Id?.value) {
                    price.val = formatCurrencyESM(
                      foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c === null
                        ? 0
                        : foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c
                            ?.value
                    );
                    price.originalValue = formatCurrencyESM(
                      foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c === null
                        ? 0
                        : foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c
                            ?.originalValue
                    );
                  } else {
                    if (rootItemId !== undefined) {
                      // find child prices recursively
                      try {
                        const childProduct = await this.findLineItemRecursively(
                          foundSourceRow[0]?.lineItems?.records,
                          price?.orgProdId
                        );
                        if (
                          childProduct !== undefined &&
                          childProduct !== null
                        ) {
                          price.val = formatCurrencyESM(
                            childProduct?.vlocity_cmt__RecurringTotal__c ===
                              null
                              ? 0
                              : childProduct?.vlocity_cmt__RecurringTotal__c
                                  .value
                          );
                          price.originalValue = formatCurrencyESM(
                            childProduct?.vlocity_cmt__RecurringTotal__c ===
                              null
                              ? 0
                              : childProduct?.vlocity_cmt__RecurringTotal__c
                                  .originalValue
                          );
                        }
                      } catch (e) {
                        console.log(e.message);
                      }
                    }
                  }
                }
              } else {
                row[this._RECURRING_TOTAL_FIELD][0].val = formatCurrencyESM(
                  foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c === null
                    ? 0
                    : this.isObject(
                        foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c
                      )
                    ? foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c.value
                    : foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c
                );
                row[this._RECURRING_TOTAL_FIELD][0].originalValue =
                  formatCurrencyESM(
                    foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c === null
                      ? 0
                      : this.isObject(
                          foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c
                        )
                      ? foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c
                          .originalValue
                      : foundSourceRow[0]?.vlocity_cmt__RecurringTotal__c
                  );
              }
            }

            if (row[this._ONETIME_TOTAL_FIELD] && foundSourceRow?.length > 0) {
              if (row[this._ONETIME_TOTAL_FIELD].length > 1) {
                for (let price of row[this._ONETIME_TOTAL_FIELD]) {
                  const rootItemId = price?.orgProdId;
                  if (price?.orgProdId === foundSourceRow[0].Id.value) {
                    price.val = formatCurrencyESM(
                      foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c === null
                        ? 0
                        : foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c?.value
                    );
                    price.originalValue = formatCurrencyESM(
                      foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c === null
                        ? 0
                        : foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c
                            ?.originalValue
                    );
                  } else {
                    if (rootItemId !== undefined) {
                      // find child prices recursively
                      try {
                        let childProduct = await this.findLineItemRecursively(
                          foundSourceRow[0]?.lineItems?.records,
                          price?.orgProdId
                        );
                        if (
                          childProduct !== undefined &&
                          childProduct !== null
                        ) {
                          price.val = formatCurrencyESM(
                            childProduct?.vlocity_cmt__OneTimeTotal__c === null
                              ? 0
                              : childProduct?.vlocity_cmt__OneTimeTotal__c.value
                          );
                          price.originalValue = formatCurrencyESM(
                            childProduct?.vlocity_cmt__OneTimeTotal__c === null
                              ? 0
                              : childProduct?.vlocity_cmt__OneTimeTotal__c
                                  .originalValue
                          );
                        }
                      } catch (e) {
                        console.log(e.message);
                      }
                    }
                  }
                }
              } else {
                row[this._ONETIME_TOTAL_FIELD][0].val = formatCurrencyESM(
                  foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c === null
                    ? 0
                    : this.isObject(
                        foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c
                      )
                    ? foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c.value
                    : foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c
                );
                row[this._ONETIME_TOTAL_FIELD][0].originalValue =
                  formatCurrencyESM(
                    foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c === null
                      ? 0
                      : this.isObject(
                          foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c
                        )
                      ? foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c
                          .originalValue
                      : foundSourceRow[0]?.vlocity_cmt__OneTimeTotal__c
                  );
              }
            }
          }
          this.tableData = [];
          this.tableData = newTable;
          this.showTable = this.tableData.length > 0;
        } catch (e) {
          console.log(`Failed at processing currency formatting ${e?.message}`);
        }
      } else {
        this.showTable = this.tableData.length > 0;
      }
    } else {
      this.showTable = this.tableData.length > 0;
    }
  }

  isObject(variable) {
    return typeof variable === "object" && variable !== null;
  }

  findLineItemRecursively(records, lineItemId) {
    return new Promise(async (resolve, reject) => {
      if (records) {
        for (const rec of records) {
          if (rec.Id.value === lineItemId) {
            return resolve(rec);
          }
          if (rec?.lineItems?.records) {
            try {
              const found = await this.findLineItemRecursively(
                rec.lineItems.records,
                lineItemId
              );
              if (found) {
                return resolve(found);
              }
            } catch (error) {
              return reject(error);
            }
          }
        }
        resolve(null);
      } else {
        resolve(null);
      }
    });
  }
}