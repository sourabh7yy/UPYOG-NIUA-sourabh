import React, { useMemo, useState, useEffect } from "react";
import {
  Table,
  Header,
  Card,
  SearchField,
  TextInput,
  SubmitBar,
  Loader,
  Dropdown,
} from "@upyog/digit-ui-react-components";
import { useForm } from "react-hook-form";
import { useTranslation } from "react-i18next";
import { useHistory } from "react-router-dom";

const ESTPropertyAllotteeDetails = () => {
  const { t } = useTranslation();
  const history = useHistory();
  const tenantId = Digit.ULBService.getCurrentTenantId();
  const [selectedStatus, setSelectedStatus] = useState(null);

  const [filteredData, setFilteredData] = useState([]);
  const [loading, setLoading] = useState(true);
  const { register, handleSubmit, reset } = useForm();
  const isMountedRef = React.useRef(true);

  useEffect(() => {
    fetchAllotmentData();
    return () => {
      isMountedRef.current = false;
    };
  }, []);

  const fetchAllotmentData = async (searchParams = {}) => {
    if (!isMountedRef.current) return;
    setLoading(true);
    
    try {
      const response = await Digit.ESTService.allotmentSearch({
        tenantId,
        filters: {
          tenantId,
          ...searchParams
        }
      });
      
      if (!isMountedRef.current) return;
      const allotments = response?.Allotments || [];
      setFilteredData(allotments);
    } catch (error) {
      console.error("Error fetching allotment data:", error);
      if (isMountedRef.current) {
        setFilteredData([]);
      }
    } finally {
      if (isMountedRef.current)
        setLoading(false);
    }
  };
  const { data: allotmentStatusData } = Digit.Hooks.useCustomMDMS(
  Digit.ULBService.getStateId(),
  "Estate",
  [{ name: "AllotmentStatus" }],
  {
    select: (data) => data?.Estate?.AllotmentStatus || [],
  }
);

  const onSubmit = (data, event) => {
  event.preventDefault(); // Prevent form submission and page refresh
  const searchParams = {};
  if (data.assetNumber?.trim()) searchParams.assetNo = data.assetNumber.trim();
  if (data.alloteeName?.trim()) searchParams.alloteeName = data.alloteeName.trim();
  if (selectedStatus?.code) searchParams.status = selectedStatus.code;
  
  fetchAllotmentData(searchParams);
};

const clearFilters = (event) => {
  event.preventDefault(); // Prevent page refresh
  reset({ assetNumber: "", alloteeName: "" });
  setSelectedStatus(null);
  fetchAllotmentData();
};


  const GetCell = (value) => {
    if (!value || value === "string" || value === "0" || value === 0) {
      return <span className="cell-text">N/A</span>;
    }
    return <span className="cell-text">{value}</span>;
  };

  const columns = useMemo(
    () => [
      { 
        Header: t("EST_ASSET_NUMBER"), 
        accessor: "assetNo", 
        disableSortBy: true, 
        Cell: ({ row }) => (
          <span 
            style={{ color: "#a82227", cursor: "pointer", textDecoration: "underline" }}
            onClick={() => history.push(`/upyog-ui/employee/est/application-details/${row.original.assetNo}`)}
          >
            {row.original.assetNo || "N/A"}
          </span>
        )
      },
      { 
        Header: t("EST_ALLOTTEE_NAME"), 
        accessor: "alloteeName", 
        disableSortBy: true, 
        Cell: ({ row }) => GetCell(row.original.alloteeName) 
      },
      { 
        Header: t("EST_PHONE_NUMBER"), 
        accessor: "mobileNo", 
        disableSortBy: true, 
        Cell: ({ row }) => GetCell(row.original.mobileNo) 
      },
      { 
        Header: t("EST_MONTHLY_RENT"), 
        accessor: "monthlyRent", 
        disableSortBy: true, 
        Cell: ({ row }) => {
          const rent = row.original.monthlyRent;
          return GetCell(rent && rent !== "string" && rent !== 0 ? `₹${rent}` : "");
        } 
      },
      { 
        Header: t("EST_STATUS"), 
        accessor: "status", 
        disableSortBy: true, 
        Cell: ({ row }) => GetCell(row.original.status || "ACTIVE") 
      },
    ],
    [t, history]
  );

  if (loading) return <Loader />;

  return (
    <div>
      <Header>{t("EST_COMMON_ALLOTTEE_DETAILS")}</Header>
      
      <Card className="card-search-heading">
        <span style={{color:"#505A5F"}}>{t("Provide at least one parameter to search for allottee details")}</span>
      </Card>
      
      <Card>
        <form onSubmit={handleSubmit(onSubmit)}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: "16px", alignItems: "end" }}>
            <SearchField>
              <label>{t("EST_ASSET_NUMBER")}</label>
              <TextInput name="assetNumber" inputRef={register("assetNumber")}/>
            </SearchField>

            <SearchField>
              <label>{t("EST_ALLOTTEE_NAME")}</label>
              <TextInput name="alloteeName" inputRef={register("alloteeName")}/>
            </SearchField>
            <SearchField>
  <label>{t("EST_ALLOTMENT_STATUS")}</label>
  <Dropdown
    option={allotmentStatusData?.map(item => ({
      code: item.code,
      i18nKey: item.name,
      value: item.code
    })) || []}
    optionKey="i18nKey"
    selected={selectedStatus}
    select={setSelectedStatus}
    placeholder={t("EST_SELECT_STATUS")}
    t={t}
  />
</SearchField>

            <SearchField>
              <SubmitBar label={t("ES_COMMON_SEARCH")} submit />
              <p style={{ marginTop: "10px", cursor: "pointer" }} onClick={clearFilters}>
                {t("ES_COMMON_CLEAR_ALL")}
              </p>
            </SearchField>
          </div>
        </form>
      </Card>

      <Table
        t={t}
        data={filteredData}
        columns={columns}
        totalRecords={filteredData.length}
        isPaginationRequired={true}
        pageSizeLimit={10}
        manualPagination={false}
        disableSort={true}
        getCellProps={() => ({
          style: {
            padding: "20px 18px",
            fontSize: "16px",
            textAlign: "left",
            borderBottom: "1px solid #e0e0e0",
          },
        })}
      />
    </div>
  );
};

export default ESTPropertyAllotteeDetails;
