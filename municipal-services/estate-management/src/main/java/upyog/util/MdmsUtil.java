package upyog.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import upyog.client.MdmsClient;
import upyog.config.EstateConfiguration;
import upyog.repository.ServiceRequestRepository;
import lombok.extern.slf4j.Slf4j;
import net.minidev.json.JSONArray;
import org.egov.common.contract.request.RequestInfo;
import org.egov.mdms.model.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

import static upyog.config.ServiceConstants.*;

@Slf4j
@Component
public class MdmsUtil {

   // @Autowired
    //private MdmsClient mdmsFeignClient;

    @Autowired
    private ObjectMapper mapper;

    @Autowired
    private EstateConfiguration configs;
    
    @Autowired
    private ServiceRequestRepository serviceRequestRepository;
    
    public Object mDMSCall(RequestInfo requestInfo, String tenantId) {
        MdmsCriteriaReq mdmsCriteriaReq = getMDMSRequest(requestInfo, tenantId);
        Object result = serviceRequestRepository.fetchResult(getMdmsSearchUrl(), mdmsCriteriaReq);
        return result;
    }
    
    public StringBuilder getMdmsSearchUrl() {
        return new StringBuilder().append(configs.getMdmsHost()).append(configs.getMdmsEndPoint());
    }
    
    public MdmsCriteriaReq getMDMSRequest(RequestInfo requestInfo, String tenantId) {
        List<ModuleDetail> moduleRequest = getEstateModuleRequest();
        
        List<ModuleDetail> moduleDetails = new ArrayList<>();
        moduleDetails.addAll(moduleRequest);

        MdmsCriteria mdmsCriteria = MdmsCriteria.builder()
                .moduleDetails(moduleDetails)
                .tenantId(tenantId.split("\\.")[0])
                .build();

        MdmsCriteriaReq mdmsCriteriaReq = MdmsCriteriaReq.builder()
                .mdmsCriteria(mdmsCriteria)
                .requestInfo(requestInfo)
                .build();
        return mdmsCriteriaReq;
    }
    
    public List<ModuleDetail> getEstateModuleRequest() {
        List<MasterDetail> estateMasterDetails = new ArrayList<>();

        estateMasterDetails.add(MasterDetail.builder()
                .name("EstateCalculationType")
                .build());

        ModuleDetail moduleDetail = ModuleDetail.builder()
                .masterDetails(estateMasterDetails)
                .moduleName("Estate")
                .build();

        return Arrays.asList(moduleDetail);
    }

    public Map<String, Map<String, JSONArray>> fetchMdmsData(RequestInfo requestInfo, String tenantId, String moduleName,
                                                             List<String> masterNameList) {
        MdmsCriteriaReq mdmsCriteriaReq = getMdmsRequest(requestInfo, tenantId, moduleName, masterNameList);
        try {
            MdmsResponse mdmsResponse = null;//mdmsFeignClient.fetchMdmsData(mdmsCriteriaReq);
            return mdmsResponse.getMdmsRes();
        } catch (Exception e) {
            log.error(ERROR_WHILE_FETCHING_FROM_MDMS, e);
        }
        return Collections.emptyMap();
    }

    private MdmsCriteriaReq getMdmsRequest(RequestInfo requestInfo, String tenantId,
                                           String moduleName, List<String> masterNameList) {
        List<MasterDetail> masterDetailList = new ArrayList<>();
        for (String masterName : masterNameList) {
            MasterDetail masterDetail = new MasterDetail();
            masterDetail.setName(masterName);
            masterDetailList.add(masterDetail);
        }

        ModuleDetail moduleDetail = new ModuleDetail();
        moduleDetail.setMasterDetails(masterDetailList);
        moduleDetail.setModuleName(moduleName);
        List<ModuleDetail> moduleDetailList = new ArrayList<>();
        moduleDetailList.add(moduleDetail);

        MdmsCriteria mdmsCriteria = new MdmsCriteria();
        mdmsCriteria.setTenantId(tenantId.split("\\.")[0]);
        mdmsCriteria.setModuleDetails(moduleDetailList);

        MdmsCriteriaReq mdmsCriteriaReq = new MdmsCriteriaReq();
        mdmsCriteriaReq.setMdmsCriteria(mdmsCriteria);
        mdmsCriteriaReq.setRequestInfo(requestInfo);

        return mdmsCriteriaReq;
    }
}
