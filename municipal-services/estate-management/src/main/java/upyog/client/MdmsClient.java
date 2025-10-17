package upyog.client;

import org.egov.mdms.model.MdmsCriteriaReq;
import org.egov.mdms.model.MdmsResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "mdms-service", url = "${mdms.service.host}${mdms.service.endpoint}")
public interface MdmsClient {

    @PostMapping()
    MdmsResponse fetchMdmsData(@RequestBody MdmsCriteriaReq request);
}
