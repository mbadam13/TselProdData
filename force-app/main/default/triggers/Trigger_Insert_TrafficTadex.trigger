/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 12-15-2023
 * @last modified by  : Diky Nurosid
 **/
trigger Trigger_Insert_TrafficTadex on Traffic__c(before insert) {
    Map < String, Business_Model_Category__c > mapbmc_text_rec = new Map < String, Business_Model_Category__c > ();
    //Integer lenght_tadexBmcText = tadexBmcText.length();
	String traffic_prefix = '';
	String tadexBmcText = '';    
    
	for (Traffic__c newTraffics: trigger.new) {
	//	if (newTraffics.Deal_Source__c == 'OMPID') {
			//-------------------------------------------------------------------
			if (label.Trigger_Insert_TrafficTadex_On == 'YES') {

				//String tadexBmcText = '';

				if (system.label.Tadex_BMC_Text != null && system.label.Tadex_BMC_Text != '') {
					tadexBmcText = system.label.Tadex_BMC_Text.toUpperCase();
				}

				List < Business_Model_Category__c > bmcList = [SELECT Id, Name, BMC_Text__c, Percentage__c, Demand_Source__c FROM Business_Model_Category__c];
				system.debug('*** bmcList = ' + bmcList.size() + ' | ' + bmcList);
				//Map < String, Business_Model_Category__c > mapbmc_text_rec = new Map < String, Business_Model_Category__c > ();
				for (Business_Model_Category__c bmcRec: bmcList) {
					if (bmcRec.BMC_Text__c != null && bmcRec.BMC_Text__c != '') {
						String bmcText = bmcRec.BMC_Text__c.toUpperCase();
						bmcText = bmcText.replace(tadexBmcText, '');
						mapbmc_text_rec.put(bmcText, bmcRec);
					}
				}
				system.debug('*** mapbmc_text_rec = ' + mapbmc_text_rec.size() + ' | ' + mapbmc_text_rec);

				Integer lenght_tadexBmcText = tadexBmcText.length();
				//String traffic_prefix = '';
				Map < String, List < Decimal >> mapAverageOMPFee = new Map < String, List < Decimal >> ();
				Set < Id > siteIds = new Set < Id > ();
				for (Traffic__c newTraffic: trigger.new) {
					if (trigger.isBefore) {
						if (trigger.isInsert) {
							for (String bmc_text: mapbmc_text_rec.keySet()) {
								system.debug('*** newTraffic.Deal__c | bmc_text = ' + newTraffic.Deal__c + ' | ' + bmc_text);
								String traffic_deal_keyword = '';
								if (newTraffic.Deal__c != null && newTraffic.Deal__c != '') {

									traffic_deal_keyword = newTraffic.Deal__c.toUpperCase();

									traffic_prefix = traffic_deal_keyword.substring(0, lenght_tadexBmcText);
									
                                    system.debug('***traffic_prefix = ' + traffic_prefix);
                                    system.debug('***tadexBmcText = ' + tadexBmcText);
                                    
									if (traffic_prefix == tadexBmcText) {
										traffic_deal_keyword = traffic_deal_keyword.substringAfter(tadexBmcText);
										traffic_deal_keyword = traffic_deal_keyword.substringBefore('_');
										system.debug('*** traffic_deal_keyword = ' + traffic_deal_keyword);
										if (traffic_deal_keyword == bmc_text) {
											system.debug('*** bmc_rec = ' + mapbmc_text_rec.get(bmc_text));
											newTraffic.Business_Model_Category__c = mapbmc_text_rec.get(bmc_text).Id;
											system.debug('*** newTraffic.Business_Model_Category__c = ' + newTraffic.Business_Model_Category__c);
											newTraffic.Demand_Source__c = mapbmc_text_rec.get(bmc_text).Demand_Source__c;
											newTraffic.Total_Telkomsel_Share__c = mapbmc_text_rec.get(bmc_text).Percentage__c;
											system.debug('*** newTraffic.Total_Telkomsel_Share__c = ' + newTraffic.Total_Telkomsel_Share__c);
											break;
										} else {
											if (bmc_text == '') {
												system.debug('*** bmc_rec yg kosong = ' + mapbmc_text_rec.get(bmc_text));
												newTraffic.Business_Model_Category__c = mapbmc_text_rec.get(bmc_text).Id;
												system.debug('*** newTraffic.Business_Model_Category__c = ' + newTraffic.Business_Model_Category__c);
												newTraffic.Demand_Source__c = mapbmc_text_rec.get(bmc_text).Demand_Source__c;
												newTraffic.Total_Telkomsel_Share__c = mapbmc_text_rec.get(bmc_text).Percentage__c;
												system.debug('*** newTraffic.Total_Telkomsel_Share__c = ' + newTraffic.Total_Telkomsel_Share__c);
												//break;
											}
										}
									}
									system.debug('*** AFTER if ' + bmc_text);
								}
							}
							Date trafficDate = newTraffic.Date__c;
							DateTime dt_trafficDate = DateTime.newInstance(trafficDate.year(), trafficDate.month(), trafficDate.day());
							String uniqueKey = dt_trafficDate.format('yyyy-MM-dd') + '_' + newTraffic.Deal_ID__c + '_' + newTraffic.Site_ID__c;
							newTraffic.Unique_Key__c = uniqueKey;
							system.debug('*** uniqueKey = ' + uniqueKey);
							if (newTraffic.Deal_Source__c == 'OMPID') {
								Date ompTrafficDate = newTraffic.Date__c;

								if (ompTrafficDate != null) {
									// Create a key based on month and Deal_Source__c
									String key = newTraffic.Account_Name__c + String.valueOf(ompTrafficDate.month()) + '_' + newTraffic.Deal_Source__c + newTraffic.Site_ID__c;

									if (!mapAverageOMPFee.containsKey(key)) {
										mapAverageOMPFee.put(key, new List < Decimal > ());
									}

									mapAverageOMPFee.get(key).add(newTraffic.Fee__c);
								}
							}
						}
					}
				}

				if (newTraffics.Deal_Source__c == 'OMPID') {
					System.debug(mapAverageOMPFee);

					// Map untuk menyimpan nilai sum dan count untuk setiap Account_Name__c
					Map < String, Decimal > sumMap = new Map < String, Decimal > ();
					Map < String, Integer > countMap = new Map < String, Integer > ();

					// Menghitung sum dan count untuk setiap key
					for (String key: mapAverageOMPFee.keySet()) {
						List < Decimal > feeList = mapAverageOMPFee.get(key);

						String accountNameMonth = key.split('_')[0];

						Decimal sum = sumMap.containsKey(accountNameMonth) ? sumMap.get(accountNameMonth) : 0;
						Integer count = countMap.containsKey(accountNameMonth) ? countMap.get(accountNameMonth) : 0;

						// Menambahkan nilai ke sum
						for (Decimal fee: feeList) {
							sum += fee;
							count++;
						}

						// Menyimpan sum dan count kembali ke Map
						sumMap.put(accountNameMonth, sum);
						countMap.put(accountNameMonth, count);
					}

					// Setelah menghitung ulang rata-rata
					Map < String, Decimal > recalculatedAverages = new Map < String, Decimal > ();
					for (String accountNameMonth: sumMap.keySet()) {
						Decimal sum = sumMap.get(accountNameMonth);
						Integer count = countMap.get(accountNameMonth);

						// Calculate the average fee
						Decimal average = count > 0 ? sum / count : 0;

						// Save the recalculated average for the specific Account_Name__c
						recalculatedAverages.put(accountNameMonth, average);
					}

					System.debug('recalculatedAverages ==> ' + recalculatedAverages);


					// Update the records with the calculated average fee
					for (Traffic__c newTraffic: trigger.new) {
						Date ompTrafficDate2 = newTraffic.Date__c;
						String accountNameMonth = newTraffic.Account_Name__c + String.valueOf(ompTrafficDate2.month());
						Decimal recalculateAverage = recalculatedAverages.get(accountNameMonth);

						// Set the recalculated average fee
						newTraffic.Fee__c = recalculateAverage;
						System.debug('ACCOUNT ID : ' + newTraffic.Account_Name__c + ' Fee : ' + recalculateAverage);
					}
				}
				


				UpdateAdditionalSettingInTraffic_Batch batchUpdateTraffic = new UpdateAdditionalSettingInTraffic_Batch();
				Database.executeBatch(batchUpdateTraffic, 50);
			}
			//-------------------------------------------------------------------
	//	}
       
	}
}