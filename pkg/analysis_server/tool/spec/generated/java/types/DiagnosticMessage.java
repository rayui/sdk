/*
 * Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
 * for details. All rights reserved. Use of this source code is governed by a
 * BSD-style license that can be found in the LICENSE file.
 *
 * This file has been automatically generated. Please do not edit it manually.
 * To regenerate the file, use the script "pkg/analysis_server/tool/spec/generate_files".
 */
package org.dartlang.analysis.server.protocol;

import java.util.Arrays;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;
import com.google.dart.server.utilities.general.JsonUtilities;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonPrimitive;

/**
 * A message associated with a diagnostic.
 *
 * For example, if the diagnostic is reporting that a variable has been referenced before it was
 * declared, it might have a diagnostic message that indicates where the variable is declared.
 *
 * @coverage dart.server.generated.types
 */
@SuppressWarnings("unused")
public class DiagnosticMessage {

  public static final List<DiagnosticMessage> EMPTY_LIST = List.of();

  /**
   * The message to be displayed to the user.
   */
  private final String message;

  /**
   * The location associated with or referenced by the message. Clients should provide the ability to
   * navigate to the location.
   */
  private final Location location;

  /**
   * Constructor for {@link DiagnosticMessage}.
   */
  public DiagnosticMessage(String message, Location location) {
    this.message = message;
    this.location = location;
  }

  @Override
  public boolean equals(Object obj) {
    if (obj instanceof DiagnosticMessage other) {
      return
        Objects.equals(other.message, message) &&
        Objects.equals(other.location, location);
    }
    return false;
  }

  public static DiagnosticMessage fromJson(JsonObject jsonObject) {
    String message = jsonObject.get("message").getAsString();
    Location location = Location.fromJson(jsonObject.get("location").getAsJsonObject());
    return new DiagnosticMessage(message, location);
  }

  public static List<DiagnosticMessage> fromJsonArray(JsonArray jsonArray) {
    if (jsonArray == null) {
      return EMPTY_LIST;
    }
    List<DiagnosticMessage> list = new ArrayList<>(jsonArray.size());
    for (final JsonElement element : jsonArray) {
      list.add(fromJson(element.getAsJsonObject()));
    }
    return list;
  }

  /**
   * The location associated with or referenced by the message. Clients should provide the ability to
   * navigate to the location.
   */
  public Location getLocation() {
    return location;
  }

  /**
   * The message to be displayed to the user.
   */
  public String getMessage() {
    return message;
  }

  @Override
  public int hashCode() {
    return Objects.hash(
      message,
      location
    );
  }

  public JsonObject toJson() {
    JsonObject jsonObject = new JsonObject();
    jsonObject.addProperty("message", message);
    jsonObject.add("location", location.toJson());
    return jsonObject;
  }

  @Override
  public String toString() {
    StringBuilder builder = new StringBuilder();
    builder.append("[");
    builder.append("message=");
    builder.append(message);
    builder.append(", ");
    builder.append("location=");
    builder.append(location);
    builder.append("]");
    return builder.toString();
  }

}
