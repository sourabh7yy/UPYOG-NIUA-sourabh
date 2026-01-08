import React, { useCallback, useMemo, useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import {
  TextInput,
  SubmitBar,
  SearchForm,
  SearchField,
  Table,
  Card,
  Loader,
  Header,
  Dropdown,
} from "@upyog/digit-ui-react-components";
import { Link, useHistory } from "react-router-dom";

const ESTSearchApplication = ({
  tenantId,
  isLoading,
  t,
  onSubmit,
  data,
  count,
  setShowToast,
}) => {
  const history = useHistory();

  const [selectedAssetType, setSelectedAssetType] = useState(null); // assetParentCategory
  const [selectedLocality, setSelectedLocality] = useState(null);   // localityCode
  const [properties, setProperties] = useState([]);

  const { register, handleSubmit, setValue, getValues, reset } = useForm({
    defaultValues: {
      offset: 0,
      limit: 10,
      sortBy: "createdDate",
      sortOrder: "DESC",
      estateNo: "",
    },
  });

  // 🔹 Asset Parent Category (LAND / BUILDING)
  const { data: assetTypeData } = Digit.Hooks.useCustomMDMS(
    Digit.ULBService.getStateId(),
    "ASSET",
    [{ name: "assetParentCategory" }],
    {
      select: (data) => {
        const formattedData = data?.ASSET?.assetParentCategory || [];
        return formattedData
          .filter((item) => item.active)
          .map((item) => ({
            code: item.code,
            name: item.name,
          }));
      },
    }
  );

  const assetTypeOptions =
    assetTypeData?.map((item) => ({
      code: item.code,
      i18nKey: item.name,
      label: item.name,
    })) || [];

  // 🔹 Locality options (boundary) – like create page
  const { data: fetchedLocalities } = Digit.Hooks.useBoundaryLocalities(
    tenantId,
    "revenue",
    { enabled: !!tenantId },
    t
  );

  const localityOptions =
    fetchedLocalities?.map((loc) => ({
      ...loc,
      code: loc.code,
      i18nKey: loc.name || loc.i18nKey || loc.label,
      label: loc.name || loc.label || loc.code,
    })) || [];

  // 🔹 Submit handler: send clean payload to parent
  const handleFormSubmit = (formData) => {
    const searchData = {
      ...formData,
      assetParentCategory: selectedAssetType?.code || undefined,
      localityCode: selectedLocality?.code || undefined,
    };

    console.log("Search data being sent:", searchData);
    onSubmit(searchData);
  };

  useEffect(() => {
    register("offset", 0);
    register("limit", 10);
    register("sortBy", "createdDate");
    register("sortOrder", "DESC");
  }, [register]);

  // 🔹 Apply frontend filtering (type + locality) over API data
  useEffect(() => {
    if (!Array.isArray(data)) return;

    let result = data;

    // Filter by asset type (LAND/BUILDING)
    if (selectedAssetType?.code) {
      const selectedCode = selectedAssetType.code.toUpperCase();
      result = result.filter((asset) => {
        const type = (asset.assetType || asset.assetParentCategory || "").toUpperCase();
        return type === selectedCode;
      });
    }

    // Filter by locality code
    if (selectedLocality?.code) {
      const locCode = selectedLocality.code.toUpperCase();
      result = result.filter((asset) => {
        const assetLocCode = (
          asset.localityCode ||
          asset.locality?.code ||
          asset.locality
        );
        return assetLocCode && assetLocCode.toUpperCase() === locCode;
      });
    }

    setProperties(result);
  }, [data, selectedAssetType, selectedLocality]);

  const GetCell = (value) => <span className="cell-text">{value || "N/A"}</span>;

  const handleAllotAsset = (asset) => {
    history.push("/upyog-ui/employee/est/assignassets/info", { assetData: asset });
  };

  const columns = useMemo(
    () => [
      {
        Header: "Asset Number",
        accessor: "estateNo",
        disableSortBy: true,
        Cell: ({ row }) => (
          <div>
            <span className="link">
              <Link to={`application-details/${row.original["estateNo"]}`}>
                {row.original["estateNo"]}
              </Link>
            </span>
          </div>
        ),
      },
      {
        Header: "Asset Ref",
        Cell: ({ row }) => GetCell(row.original["refAssetNo"]),
        disableSortBy: true,
      },
      {
        Header: "Building Name",
        Cell: ({ row }) => GetCell(row.original["buildingName"]),
        disableSortBy: true,
      },
      {
        Header: "Locality",
        Cell: ({ row }) => GetCell(row.original["locality"]),
        disableSortBy: true,
      },
      {
        Header: "Plot Area",
        Cell: ({ row }) => GetCell(row.original["totalFloorArea"]),
        disableSortBy: true,
      },
      {
        Header: "Dimensions",
        Cell: ({ row }) =>
          GetCell(`${row.original["dimensionLength"]} x ${row.original["dimensionWidth"]}`),
        disableSortBy: true,
      },
      {
        Header: "Asset Type",
        Cell: ({ row }) => GetCell(row.original["assetType"]),
        disableSortBy: true,
      },
      {
        Header: "Rate/sqft",
        Cell: ({ row }) => GetCell(row.original["rate"]),
        disableSortBy: true,
      },
      {
        Header: "Status",
        Cell: ({ row }) => GetCell(row.original["assetStatus"]),
        disableSortBy: true,
      },
      {
        Header: "Action",
        Cell: ({ row }) => {
          const isAllotted = row.original["assetStatus"] === "Allotted";
          return (
            <button
              onClick={() => !isAllotted && handleAllotAsset(row.original)}
              style={{
                backgroundColor: isAllotted ? "#ccc" : "#007bff",
                color: "white",
                border: "none",
                padding: "6px 10px",
                borderRadius: "4px",
                cursor: isAllotted ? "not-allowed" : "pointer",
                fontSize: "12px",
              }}
              disabled={isAllotted}
            >
              Allot Asset
            </button>
          );
        },
        disableSortBy: true,
      },
    ],
    []
  );

  const onSort = useCallback(
    (args) => {
      if (args.length === 0) return;
      setValue("sortBy", args.id);
      setValue("sortOrder", args.desc ? "DESC" : "ASC");
    },
    [setValue]
  );

  function onPageSizeChange(e) {
    setValue("limit", Number(e.target.value));
    handleSubmit(handleFormSubmit)();
  }

  function nextPage() {
    setValue("offset", getValues("offset") + getValues("limit"));
    handleSubmit(handleFormSubmit)();
  }

  function previousPage() {
    setValue("offset", getValues("offset") - getValues("limit"));
    handleSubmit(handleFormSubmit)();
  }

  return (
    <React.Fragment>
      <div>
        <Header>{t("EST_SEARCH_APPLICATIONS")}</Header>

        <SearchForm onSubmit={handleFormSubmit} handleSubmit={handleSubmit}>
          {/* Asset Number */}
          <SearchField>
            <label>{t("EST_SEARCH_ASSET_NUMBER")}</label>
            <TextInput name="estateNo" inputRef={register({})} />
          </SearchField>

          {/* Locality dropdown */}
          <SearchField>
            <label>{t("EST_LOCALITY")}</label>
            <Dropdown
              option={localityOptions}
              optionKey="i18nKey"
              selected={selectedLocality}
              select={setSelectedLocality}
              placeholder={t("EST_SELECT_LOCALITY")}
              t={t}
              optionCardStyles={{ overflowY: "auto", maxHeight: "300px" }}
            />
          </SearchField>

          {/* Asset Type (parent category) */}
          <SearchField>
            <label>{t("EST_ASSET_TYPE")}</label>
            <Dropdown
              option={assetTypeOptions}
              optionKey="i18nKey"
              selected={selectedAssetType}
              select={setSelectedAssetType}
              placeholder={t("EST_SELECT_ASSET_TYPE")}
              t={t}
            />
          </SearchField>

          {/* Submit + Clear */}
          <SearchField className="submit">
            <SubmitBar label={t("ES_COMMON_SEARCH")} submit />
            <p
              style={{ marginTop: "10px", cursor: "pointer" }}
              onClick={() => {
                reset({
                  estateNo: "",
                });
                setSelectedAssetType(null);
                setSelectedLocality(null);
                setShowToast(null);
              }}
            >
              {t("ES_COMMON_CLEAR_ALL")}
            </p>
          </SearchField>
        </SearchForm>

        {/* Results */}
        {!isLoading && data?.display ? (
          <Card style={{ marginTop: 20, textAlign: "center" }}>
            {t(data.display)
              .split("\\n")
              .map((text, index) => (
                <p key={index}>{text}</p>
              ))}

            <button
              onClick={() => history.push("/upyog-ui/employee/est/create-asset")}
              style={{
                backgroundColor: "#007bff",
                color: "white",
                border: "none",
                padding: "10px 10px",
                borderRadius: "4px",
                cursor: "pointer",
                marginTop: "10px",
              }}
            >
              {t("EST_CREATE_ASSET")}
            </button>
          </Card>
        ) : !isLoading && Array.isArray(data) && data.length > 0 ? (
          <div style={{ overflowX: "auto", width: "100%", marginTop: "20px" }}>
            <Table
              t={t}
              data={properties}
              totalRecords={count}
              columns={columns}
              getCellProps={() => ({
                style: {
                  minWidth: "100px",
                  padding: "8px 6px",
                  fontSize: "12px",
                  textAlign: "center",
                  whiteSpace: "nowrap",
                },
              })}
              onPageSizeChange={onPageSizeChange}
              currentPage={getValues("offset") / getValues("limit")}
              onNextPage={nextPage}
              onPrevPage={previousPage}
              pageSizeLimit={getValues("limit")}
              onSort={onSort}
              disableSort={false}
              sortParams={[
                {
                  id: getValues("sortBy"),
                  desc: getValues("sortOrder") === "DESC",
                },
              ]}
            />
          </div>
        ) : (
          isLoading && <Loader />
        )}
      </div>
    </React.Fragment>
  );
};

export default ESTSearchApplication;
