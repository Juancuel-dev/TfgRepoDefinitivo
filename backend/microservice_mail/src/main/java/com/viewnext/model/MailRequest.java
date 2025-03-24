package com.viewnext.model;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class MailRequest {

    private String to;
    private String subject;
    private String fileName;
}
